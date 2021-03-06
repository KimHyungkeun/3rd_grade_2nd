#include <list.h>
#include <proc/sched.h>
#include <mem/malloc.h>
#include <proc/proc.h>
#include <proc/switch.h>
#include <interrupt.h>

extern struct list plist;
extern struct list rlist;
extern struct list runq[RQ_NQS];

extern struct process procs[PROC_NUM_MAX];
extern struct process *idle_process;
struct process *latest;

bool more_prio(const struct list_elem *a, const struct list_elem *b,void *aux);
int scheduling; 					// interrupt.c


struct process* get_next_proc(void) 
{
	int idx;
	bool found = false;
	struct process *next = NULL;
	struct list_elem *elem ;
	

	/* 
	   You shoud modify this function...
	   Browse the 'runq' array 
	*/

	for (idx = 0; idx < RQ_NQS; idx++) {

		for (elem = list_begin(&runq[idx]); elem != list_end(&runq[idx]); elem = list_next(elem)) {
			struct process *p = list_entry(elem, struct process, elem_stat); //runq에 존재하는 모든 프로세스들에 대해 검사한다.

			if (cur_process->pid == 0 && p->state == PROC_RUN) { //프로세스가 0번이고 state가 RUN상태면
				return p; //해당 프로세스를 반환한다.
			}
	
		}
		
	}
	
	next = idle_process; //즉, 0번이 아닌 프로세스라면
	return next; // 0번으로 스케쥴링 후 리턴
}

void schedule(void)
{
	struct process *cur;
	struct process *next;
	struct process *p;

	struct list_elem *elem;
	bool flag = true;
	

	

	/* You shoud modify this function.... */
	intr_disable(); //인터럽트 비활성화
	proc_wake(); //프로세스를 깨운다

	
	
	if (cur_process->state == PROC_STOP) //프로세스가 STOP상태면
		printk("Proc %d I/O at %d\n", cur_process->pid, cur_process->time_used); //해당 프로세스에 대한 정보를 출력
	
	cur = cur_process; //현재 프로세스를 cur 변수에 넣음
	next = get_next_proc(); //다른 프로세스들을 스케쥴링한다.
	cur_process = next; //다음 프로세스를 현재의 프로세스로 설정
	

	if (next->pid != 0) { //다음 프로세스가 0이 아닐 경우
		
		for (elem = list_begin(&plist); elem != list_end(&plist); elem = list_next(elem)) { 
			p = list_entry(elem, struct process, elem_all); //프로세스 전체 배열인 plist에 대해 검사한다
			if (p->pid != 0) { //만약 프로세스가 0번이 아니고 run 상태면
				if (p -> state == PROC_RUN) {
						
					if (flag == true) //프로세스 리스트의 마지막이면 쉼표를 출력하지 않고
						flag = false;
					else
						printk(", "); //만약 아니라면 쉼표를 출력
					 
					printk("#= %d p= %d c= %d u= %d", p->pid, p->priority, p->time_slice, p->time_used); //pid, priority,time_slice, time_used 출력
					
				}
				
			}
		}


		printk("\n"); 
		printk("Selected # = %d\n", next->pid); //선택된 다음 프로세스 번호를 출력

	}

	cur_process->time_slice = 0; //time_slice를 0으로 초기화

	
	switch_process(cur, next); //프로세스 스위칭 (스위칭 동안에는 인터럽트 핸들러가 발생해선 안됨)
	intr_enable(); //인터럽트 활성화
	
	return ;
	
}


