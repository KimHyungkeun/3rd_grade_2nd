#include <mem/palloc.h>
#include <bitmap.h>
#include <type.h>
#include <round.h>
#include <mem/mm.h>
#include <synch.h>
#include <device/console.h>
#include <mem/paging.h>
#include<mem/swap.h>

/* Page allocator.  Hands out memory in page-size (or
   page-multiple) chunks.  
   */
/* pool for memory */
struct memory_pool
{
	struct lock lock;                   
	struct bitmap *bitmap; 
	uint32_t *addr;                    
};
/* kernel heap page struct */
struct khpage{
	uint16_t page_type;
	uint16_t nalloc;
	uint32_t used_bit[4];
	struct khpage *next;
};

/* free list */
struct freelist{
	struct khpage *list;
	int nfree;
};

static struct khpage *khpage_list;
static struct freelist freelist;
static uint32_t page_alloc_index;

struct memory_pool kernelpool;
struct memory_pool userpool;

/* Initializes the page allocator. */
//
	void
init_palloc (void) 
{
	uint32_t bit = 8; // 1byte = 8bit

	uint32_t bitmap_kernel_pool = (USER_POOL_START - KERNEL_ADDR) / PAGE_SIZE; //커널 풀 설정
	uint32_t bitmap_user_pool = (RKERNEL_HEAP_START - USER_POOL_START) / PAGE_SIZE;//유저 풀 설정
	
	uint32_t bitmapkernel_blocksize = bitmap_kernel_pool / bit; //비트맵 커널에 대한 블록 사이즈
	uint32_t bitmapuser_blocksize = bitmap_user_pool / bit; //비트맵 유저에 대한 블록 사이즈

	lock_init(&kernelpool.lock); //kernelpool을 lock 시킴
	lock_init(&userpool.lock); //userpool을 lock 시킴
	

	kernelpool.addr = (uint32_t *)KERNEL_ADDR; //커널풀의 시작 주소
	userpool.addr = (uint32_t *)USER_POOL_START; //유저 풀의 시작주소

	//커널 풀에 대한 비트맵 생성
	kernelpool.bitmap = create_bitmap(bitmap_kernel_pool, (void *)kernelpool.addr, bitmap_kernel_pool / bit);
	//유저 풀에 대한 비트맵 설정
	userpool.bitmap = create_bitmap(bitmap_user_pool, (void *)userpool.addr, bitmapkernel_blocksize);
	
	set_bitmap(kernelpool.bitmap, 0, true); //생성한 커널 비트맵 설정
	set_bitmap(userpool.bitmap, 0, true); //생성한 유저 비트맵 설정

}



/* Obtains and returns a group of PAGE_CNT contiguous free pages.
   */
	uint32_t *
palloc_get_multiple_page (enum palloc_flags flags, size_t page_cnt) 
{
	void * pages = NULL;
	size_t page_idx; //page의 인덱스 번호
	struct memory_pool *kp = &kernelpool; //커널 풀 주소를 담을 영역
	struct memory_pool *up = &userpool; //유저 풀 주소를 담을 영역
	

	if (page_cnt == 0)  //page_cnt가 0이면 NULL값 리턴
		return NULL;
	
	if (flags == kernel_area) { //커널 풀에 대한 플래그의 경우

		page_idx = find_set_bitmap(kp->bitmap, 0, page_cnt, false); 

		if(pages == NULL) //해당 페이지가 NULL이라면
			pages = (void*)((size_t)kp -> addr + page_idx * PAGE_SIZE); //커널 풀 시작주소 시작하여 page 할당
		

		if (pages != NULL) 
			memset (pages, 0, PAGE_SIZE * page_cnt); //NULL이 아닌 부분은 모두 0으로 채워둔다
		
	}

	else if (flags == user_area) { //유저 풀에 대한 플래그의 경우
	
		page_idx = find_set_bitmap(up->bitmap, 0, page_cnt, false);

		if(pages == NULL)
			pages = (void*)((size_t)up -> addr + page_idx * PAGE_SIZE); //유저 풀 시작주소 시작하여 page 할당
		

		if (pages != NULL) 
			memset (pages, 0, PAGE_SIZE * page_cnt); //NULL이 아닌 부분은 모두 0으로 채워둔다
		

	}

	else
		return NULL;

	return (uint32_t*)pages; //할당한 page를 반환
	 
	
}

/* Obtains a single free page and returns its address.
   */
	uint32_t *
palloc_get_one_page (enum palloc_flags flags) 
{
	return palloc_get_multiple_page (flags, 1); //flag에 따라 커널과 유저풀 선택이 달라진다.
}

/* Frees the PAGE_CNT pages starting at PAGES. */
	void
palloc_free_multiple_page (void *pages, size_t page_cnt) 
{
	size_t page_idx;
	struct memory_pool *kp = NULL; //커널 풀을 담을 공간
	struct memory_pool *up = NULL; //유저 풀을 담을 공간
	
	if (pages == NULL || page_cnt == 0)
		return;

	if (KERNEL_ADDR <= (uint32_t *)pages && (uint32_t *)pages < USER_POOL_START) { 
		kp = &kernelpool; //page가 커널풀에 있는지 확인

		page_idx = ((size_t)pages - (size_t)kp->addr) / PAGE_SIZE; //원하는 인덱스로 간다.

		if(bitmap_contains(kp->bitmap, page_idx, page_cnt, true)) //해당 영역에 유효한 비트맵이 있다면
			set_multi_bitmap(kp->bitmap, page_idx, page_cnt, false); //그 영역의 비트맵을 모두 free시킨다.

	}
	
	else if (USER_POOL_START <= (uint32_t *)pages && (uint32_t *)pages < RKERNEL_HEAP_START) {
		up = &userpool; //page가 유저풀에 있는지 확인

		page_idx = ((size_t)pages - (size_t)up->addr) / PAGE_SIZE; //원하는 인덱스로 간다.

		if(bitmap_contains(up->bitmap, page_idx, page_cnt, true)) //해당 영역에 유효한 비트맵이 있다면
			set_multi_bitmap(up->bitmap, page_idx, page_cnt, false); //그 영역의 비트맵을 모두 free시킨다.

	}
	
	else 
		return; //유저나 커널 풀에 속한게 아니라면 종료

}

/* Frees the page at PAGE. */
	void
palloc_free_one_page (void *page) 
{
	palloc_free_multiple_page (page, 1); 
}


void palloc_pf_test(void)
{
	 uint32_t *one_page1 = palloc_get_one_page(user_area);
	 uint32_t *one_page2 = palloc_get_one_page(user_area);
	 uint32_t *two_page1 = palloc_get_multiple_page(user_area,2);
	 uint32_t *three_page;
	 printk("one_page1 = %x\n", one_page1); 
	 printk("one_page2 = %x\n", one_page2); 
	 printk("two_page1 = %x\n", two_page1);

	 printk("=----------------------------------=\n");
	 palloc_free_one_page(one_page1);
	 palloc_free_one_page(one_page2);
	 palloc_free_multiple_page(two_page1,2);

	 one_page1 = palloc_get_one_page(user_area);
	 one_page2 = palloc_get_one_page(user_area);
	 two_page1 = palloc_get_multiple_page(user_area,2);

	 printk("one_page1 = %x\n", one_page1);
	 printk("one_page2 = %x\n", one_page2);
	 printk("two_page1 = %x\n", two_page1);

	 printk("=----------------------------------=\n");
	 palloc_free_multiple_page(one_page2, 3);
	 one_page2 = palloc_get_one_page(user_area);
	 three_page = palloc_get_multiple_page(user_area,3);

	 printk("one_page1 = %x\n", one_page1);
	 printk("one_page2 = %x\n", one_page2);
	 printk("three_page = %x\n", three_page);

	 palloc_free_one_page(one_page1);
	 palloc_free_one_page(three_page);
	 three_page = (uint32_t*)((uint32_t)three_page + 0x1000);
	 palloc_free_one_page(three_page);
	 three_page = (uint32_t*)((uint32_t)three_page + 0x1000);
	 palloc_free_one_page(three_page);
	 palloc_free_one_page(one_page2);
}
