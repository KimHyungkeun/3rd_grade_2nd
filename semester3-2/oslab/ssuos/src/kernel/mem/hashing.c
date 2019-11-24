#include <device/io.h>
#include <mem/mm.h>
#include <mem/paging.h>
#include <device/console.h>
#include <proc/proc.h>
#include <interrupt.h>
#include <mem/palloc.h>
#include <ssulib.h>
#include <mem/hashing.h>


uint32_t F_IDX(uint32_t addr, uint32_t capacity) {
    return addr % ((capacity / 2) - 1);
}

uint32_t S_IDX(uint32_t addr, uint32_t capacity) {
    return (addr * 7) % ((capacity / 2) - 1) + capacity / 2;
}

void init_hash_table(void)
{
    int i,j;
	// TODO : OS_P5 assignment
    for (i = 0 ; i < CAPACITY ; i++) { //256개의 top_bucket을 설정한다
        for (j = 0 ; j < SLOT_NUM ; j++) {
            hash_table.top_buckets[i].token[j] = 0; //초기 토큰을 0으로 설정
            hash_table.top_buckets[i].slot[j].key = 0; //초기 키를 0으로 설정
            hash_table.top_buckets[i].slot[j].value = 0; //초기 value를 0으로 설정
        }
    }

    for (i = 0 ; i < CAPACITY/2 ; i++) { //128개의 bottom_bucket을 설정한다
        for (j = 0 ; j < SLOT_NUM ; j++) {
            hash_table.bottom_buckets[i].token[j] = 0; //초기 토큰을 0으로 설정
            hash_table.bottom_buckets[i].slot[j].key = 0; //초기 키를 0으로 설정
            hash_table.bottom_buckets[i].slot[j].value = 0; //초기 value를 0으로 설정
            
        }
    }
 
}

void insert_hash_table(void* pages, size_t page_idx) { //해쉬테이블에 값 넣는 함수
    
    int i,j, full_top = 0, new_hash_count = 0; //full_top : top_bucket이 꽉차있음을 알려주기 위한 변수
    uint32_t hash1_idx, hash2_idx; //hash1, hash2에 각각 적용될 bucket 인덱스
    uint32_t find_hash1, find_hash2; //새 해쉬값을 구해서 value 이동에 필요한 위치를 구하려한다.
    uint32_t idx, value, key, virt_value;
    uint32_t *virtual_address = (uint32_t *)pages; //가상주소를 담음

    // idx : hash value (F_IDX or S_IDX)
    // value : Real_address(Use VH_TO_RH)
    // key : page_index

    hash1_idx = F_IDX(virtual_address, CAPACITY); //해쉬1에 대한 인덱스
    hash2_idx = S_IDX(virtual_address, CAPACITY); //해쉬2에 대한 인덱스

    value = VH_TO_RH(virtual_address); //value에 가상주소를 실제주소로 변환한 값을 넣는다. 
    key = page_idx; //페이지 번호가 곧 키가 된다

    for (i = 0 ; i < SLOT_NUM ; i++) { //해쉬테이블(top_bucket) 설정
        if ( hash_table.top_buckets[hash1_idx].token[i] == 0 ) { //만약 해당 토큰이 0이라면
            hash_table.top_buckets[hash1_idx].token[i] = 1; //토큰을 1로 설정(값이 이미 존재한다는 뜻)
            hash_table.top_buckets[hash1_idx].slot[i].key = key; //page_idx값이 담긴 key를 넣는다
            hash_table.top_buckets[hash1_idx].slot[i].value = value; //value를 담는다.
            idx = hash1_idx;
            printk("hash value inserted in top level : idx : %d, key : %d, value : %x\n",idx,key,value);
            return;
        }

        else if ( hash_table.top_buckets[hash2_idx].token[i] == 0 ) { //만약 hash2가 가리키는 쪽의 토큰이 0이면
            hash_table.top_buckets[hash2_idx].token[i] = 1;  //토큰을 1로 설정(값이 이미 존재한다는 뜻)
            hash_table.top_buckets[hash2_idx].slot[i].key = key; //page_idx값이 담긴 key를 넣는다.
            hash_table.top_buckets[hash2_idx].slot[i].value = value; //value를 담는다
            idx = hash2_idx;
            printk("hash value inserted in top level : idx : %d, key : %d, value : %x\n",idx,key,value);
            return;
        }

        else
            full_top++; //두 해쉬값(인덱스)에 해당하는 테이블 슬롯이 꽉찼을 경우 full_top 카운터를 올린다.
        
    }

    if( full_top == SLOT_NUM ) { //슬롯이 전부 꽉 찼을 경우
         for (i = 0 ; i < SLOT_NUM ; i++) { //bottom_bucket 설정
             if ( hash_table.bottom_buckets[hash1_idx/2].token[i] == 0 ) { //초기 슬롯이 비어있다면
                hash_table.bottom_buckets[hash1_idx/2].token[i] = 1; //토큰을 1로 한다(값이 존재한다는 뜻)
                hash_table.bottom_buckets[hash1_idx/2].slot[i].key = key; //키값을 넣음
                hash_table.bottom_buckets[hash1_idx/2].slot[i].value = value; //value를 넣는다.
                idx = hash1_idx/2;
                printk("hash value inserted in bottom level : idx : %d, key : %d, value : %x\n",idx,key,value);
                return;
            }

            else if ( hash_table.bottom_buckets[hash2_idx/2].token[i] == 0 ) { //초기 슬롯이 비어있다면
                hash_table.bottom_buckets[hash2_idx/2].token[i] = 1; //토큰을 1로 한다(값이 존재한다는 뜻)
                hash_table.bottom_buckets[hash2_idx/2].slot[i].key = key; //키값을 넣음
                hash_table.bottom_buckets[hash2_idx/2].slot[i].value = value; //value를 넣음
                idx = hash2_idx/2;
                printk("hash value inserted in bottom level : idx : %d, key : %d, value : %x\n",idx,key,value);
                return;
            }

            else
                full_top++;
         }
    }

    if (full_top == SLOT_NUM * 2) { //top_bucket, bottom_bucket을 둘러봐도 빈칸이 없을때
        for (i = 0 ; i < SLOT_NUM; i++) {
            virt_value = RH_TO_VH(hash_table.top_buckets[hash1_idx].slot[i].value); //hash1에 대한 해쉬값을 다시 가상주소로 바꾼다.
            find_hash1 = F_IDX(virt_value, CAPACITY); //바꾼 가상주소로 새로운 해쉬1을 만듦
            find_hash2 = S_IDX(virt_value, CAPACITY); //바꾼 가상주소로 새로운 해쉬2를 만듦

            if(hash1_idx == find_hash1) { //구 해쉬값과 현재 해쉬값을 비교해서 같으면
                for(j = 0 ; j < SLOT_NUM ; j++) {
                    if(hash_table.top_buckets[find_hash2].token[j] == 0) { // 다른 해쉬값을 인덱스로 하여 값 설정
                        hash_table.top_buckets[find_hash2].token[j] = 1;
                        hash_table.top_buckets[find_hash2].slot[j].value = value;
                        hash_table.top_buckets[find_hash2].slot[j].key = key;
                        idx = find_hash2;
                        printk("hash value inserted in top level : idx : %d, key : %d, value : %x\n",idx,key,value);
                        return;
                    }
                }
            }

            else if(hash1_idx == find_hash2) { 
                for(j = 0 ; j < SLOT_NUM ; j++) { //구 해쉬값과 현재 해쉬값을 비교해서 같으면
                    if(hash_table.top_buckets[find_hash1].token[j] == 0) { // 다른 해쉬값을 인덱스로 하여 값 설정
                        hash_table.top_buckets[find_hash1].token[j] = 1;
                        hash_table.top_buckets[find_hash1].slot[j].value = value;
                        hash_table.top_buckets[find_hash1].slot[j].key = key;
                        idx = find_hash1;
                        printk("hash value inserted in top level : idx : %d, key : %d, value : %x\n",idx,key,value);
                        return;
                    }
                }
            }

            else
                new_hash_count++; //어떠한 경우도 해당되지 않으면 new_hash_count 카운터를 증가시킴
        }

        if (new_hash_count == SLOT_NUM) {
            for (i = 0 ; i < SLOT_NUM; i++) {
                virt_value = RH_TO_VH(hash_table.top_buckets[hash2_idx].slot[i].value); //hash2에 대한 해쉬값을 다시 가상주소로 바꾼다.
                find_hash1 = F_IDX(virt_value, CAPACITY); //바꾼 가상주소로 새로운 해쉬1을 만듦
                find_hash2 = S_IDX(virt_value, CAPACITY); //바꾼 가상주소로 새로운 해쉬2을 만듦

                if(hash2_idx == find_hash1) {
                    for(j = 0 ; j < SLOT_NUM ; j++) { //구 해쉬값과 현재 해쉬값을 비교해서 같으면
                        if(hash_table.top_buckets[find_hash2].token[j] == 0) { // 다른 해쉬값을 인덱스로 하여 값 설정
                            hash_table.top_buckets[find_hash2].token[j] = 1;
                            hash_table.top_buckets[find_hash2].slot[j].value = value;
                            hash_table.top_buckets[find_hash2].slot[j].key = key;
                            idx = find_hash2;
                            printk("hash value inserted in top level : idx : %d, key : %d, value : %x\n",idx,key,value);
                            return;
                        }
                    }
                }

                else if(hash2_idx == find_hash2) { //구 해쉬값과 현재 해쉬값을 비교해서 같으면
                    for(j = 0 ; j < SLOT_NUM ; j++) {
                        if(hash_table.top_buckets[find_hash1].token[j] == 0) {  // 다른 해쉬값을 인덱스로 하여 값 설정
                            hash_table.top_buckets[find_hash1].token[j] = 1;
                            hash_table.top_buckets[find_hash1].slot[j].value = value;
                            hash_table.top_buckets[find_hash1].slot[j].key = key;
                            idx = find_hash1;
                            printk("hash value inserted in top level : idx : %d, key : %d, value : %x\n",idx,key,value);
                            return;
                        }
                    }
                }

                else
                    new_hash_count++;
            }
        }

        if (new_hash_count == SLOT_NUM * 2) { //top_bucket이 모두 꽉찬경우 bottom_bucket 탐색시작
            for (i = 0 ; i < SLOT_NUM; i++) {
                virt_value = RH_TO_VH(hash_table.bottom_buckets[hash1_idx/2].slot[i].value); //hash2에 대한 해쉬값을 다시 가상주소로 바꾼다.
                find_hash1 = F_IDX(virt_value, CAPACITY); //바꾼 가상주소로 새로운 해쉬1을 만듦
                find_hash2 = S_IDX(virt_value, CAPACITY); //바꾼 가상주소로 새로운 해쉬2을 만듦

                if(hash1_idx/2 == find_hash1/2) { //구 해쉬값과 현재 해쉬값을 비교해서 같으면
                    for(j = 0 ; j < SLOT_NUM ; j++) {
                        if(hash_table.bottom_buckets[find_hash2/2].token[j] == 0) { // 다른 해쉬값을 인덱스로 하여 값 설정
                            hash_table.bottom_buckets[find_hash2/2].token[j] = 1;
                            hash_table.bottom_buckets[find_hash2/2].slot[j].value = value;
                            hash_table.bottom_buckets[find_hash2/2].slot[j].key = key;
                            idx = find_hash2/2;
                            printk("hash value inserted in bottom level : idx : %d, key : %d, value : %x\n",idx,key,value);
                            return;
                        }
                    }
                }

                else if(hash1_idx/2 == find_hash2/2) { //구 해쉬값과 현재 해쉬값을 비교해서 같으면
                    for(j = 0 ; j < SLOT_NUM ; j++) {
                        if(hash_table.top_buckets[find_hash1/2].token[j] == 0) { // 다른 해쉬값을 인덱스로 하여 값 설정
                            hash_table.top_buckets[find_hash1/2].token[j] = 1;
                            hash_table.top_buckets[find_hash1/2].slot[j].value = value;
                            hash_table.top_buckets[find_hash1/2].slot[j].key = key;
                            idx = find_hash1/2;
                            printk("hash value inserted in bottom level : idx : %d, key : %d, value : %x\n",idx,key,value);
                            return;
                        }
                    }
                }

                else
                    new_hash_count++;
            }
        }

        if (new_hash_count == SLOT_NUM * 3) { //다른 bottom_bucket을 탐색한다.
            for (i = 0 ; i < SLOT_NUM; i++) {
                virt_value = RH_TO_VH(hash_table.bottom_buckets[hash2_idx/2].slot[i].value);
                find_hash1 = F_IDX(virt_value, CAPACITY);
                find_hash2 = S_IDX(virt_value, CAPACITY);

                if(hash2_idx/2 == find_hash1/2) { //구 해쉬값과 현재 해쉬값을 비교해서 같으면
                    for(j = 0 ; j < SLOT_NUM ; j++) {
                        if(hash_table.bottom_buckets[find_hash2/2].token[j] == 0) { // 다른 해쉬값을 인덱스로 하여 값 설정
                            hash_table.bottom_buckets[find_hash2/2].token[j] = 1;
                            hash_table.bottom_buckets[find_hash2/2].slot[j].value = value;
                            hash_table.bottom_buckets[find_hash2/2].slot[j].key = key;
                            idx = find_hash2/2;
                            printk("hash value inserted in bottom level : idx : %d, key : %d, value : %x\n",idx,key,value);
                            return;
                        }
                    }
                }

                else if(hash2_idx/2 == find_hash2/2) { //구 해쉬값과 현재 해쉬값을 비교해서 같으면
                    for(j = 0 ; j < SLOT_NUM ; j++) {
                        if(hash_table.top_buckets[find_hash1/2].token[j] == 0) { // 다른 해쉬값을 인덱스로 하여 값 설정
                            hash_table.top_buckets[find_hash1/2].token[j] = 1;
                            hash_table.top_buckets[find_hash1/2].slot[j].value = value;
                            hash_table.top_buckets[find_hash1/2].slot[j].key = key;
                            idx = find_hash1/2;
                            printk("hash value inserted in bottom level : idx : %d, key : %d, value : %x\n",idx,key,value);
                            return;
                        }
                    }
                }

                else
                    new_hash_count++; //해쉬카운트 값만 올린다.
            }
        }
    }
    
}

void delete_hash_table(void* pages, size_t page_idx) { //해쉬테이블로부터 값을 지우는 함수
    
   int i, full_top = 0;;
   uint32_t hash1_idx, hash2_idx; 
   uint32_t idx, value, key;
   uint32_t *virtual_address = (uint32_t *)pages;
   

    // idx : hash value (F_IDX or S_IDX)
    // value : Real_address(VH_TO_RH)
    // key : page_index

    hash1_idx = F_IDX(virtual_address, CAPACITY); //해쉬1에 대한 인덱스
    hash2_idx = S_IDX(virtual_address, CAPACITY); //해쉬2에 대한 인덱스

    value = VH_TO_RH(virtual_address); //value에 가상주소를 실제주소로 변환한 값을 넣는다. 
    key = page_idx; //페이지 번호가 곧 키가 된다

    for (i = 0 ; i < SLOT_NUM ; i++) { //top_bucket에서 값을 찾아 삭제
        if ( hash_table.top_buckets[hash1_idx].slot[i].key == key ) { //해당하는 위치를 key와 hash1_idx를 이용해 찾는다
            hash_table.top_buckets[hash1_idx].token[i] = 0; //토큰을 0으로 한다. (값이 지워졌다는 뜻)
            idx = hash1_idx;
            printk("hash value deleted : idx : %d, key : %d, value : %x\n",idx,key,value);
            return;
        }

        else if ( hash_table.top_buckets[hash2_idx].slot[i].key == key ) { //해당하는 위치를 key와 hash2_idx를 이용해 찾는다.
            hash_table.top_buckets[hash2_idx].token[i] = 0; //토큰을 0으로 한다. (값이 존재하지 않음)
            idx = hash2_idx; 
            printk("hash value deleted : idx : %d, key : %d, value : %x\n",idx,key,value);
            return;
        }

        else
            full_top++; //두 해쉬값(인덱스)에 해당하는 테이블 슬롯에 원하는 값이 없을 경우 full_top 카운터 증가
    }

    if (full_top == SLOT_NUM) {
        for (i = 0 ; i < SLOT_NUM ; i++) { //bottom_bucket에서 값을 찾아 삭제
            if ( hash_table.bottom_buckets[hash1_idx/2].slot[i].key == key ) { //키와 hash1_idx를 사용해 원하는 값을 찾음
                hash_table.bottom_buckets[hash1_idx/2].token[i] = 0; //토큰을 0으로 함(값이 존재하지 않음)
                idx = hash1_idx/2;
                printk("hash value deleted : idx : %d, key : %d, value : %x\n",idx,key,value);
                return;
            }

            else if ( hash_table.bottom_buckets[hash2_idx/2].slot[i].key == key ) { //키와 hash2_idx를 사용해 원하는 값을 찾음
                hash_table.bottom_buckets[hash2_idx/2].token[i] = 0; //토큰을 0으로 함 (값이 존재하지 않음)
                idx = hash2_idx/2;
                printk("hash value deleted : idx : %d, key : %d, value : %x\n",idx,key,value);
                return;
            }

            else
                full_top++;
                
        }
    }

    if ( full_top == SLOT_NUM * 2) { //top_bucket, bottom_bucket을 모두 찾아봐도 없다면
            return; //함수를 종료한다.
    }

    

}