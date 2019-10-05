#include <list.h>
#include <proc/sched.h>
#include <mem/malloc.h>
#include <proc/proc.h>
#include <proc/switch.h>
#include <interrupt.h>WS

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

			if (p->state == PROC_RUN) { //state가 RUN상태면
				return p; //해당 프로세스를 반환한다.
			}
		}
		
	}
	
	return next;
}

void schedule(void)
{
	struct process *cur;
	struct process *next;
	struct process *p;

	struct list_elem *elem;
	bool found = false;
	int idx;
	

	/* You shoud modify this function.... */
	intr_disable(); //인터럽트 비활성화
	proc_wake(); //프로세스를 깨운다

	if (cur_process->state == PROC_STOP) //프로세스가 STOP상태면
		printk("Proc %d I/O at %d\n", cur_process->pid, cur_process->time_used); //해당 프로세스에 대한 정보를 출력

	if (cur_process->pid == 0) //프로세스가 0번이면
		next = get_next_proc(); //다른 프로세스들을 스케쥴링한다.
	
	else //프로세스가 0이 아니면
		next = idle_process; //프로세스 0번으로 스케쥴링한다
	
	cur = cur_process;
	cur_process = next;

	if (next->pid != 0) {

		for (elem = list_begin(&plist); elem != list_end(&plist); elem = list_next(elem)) { 
			p = list_entry(elem, struct process, elem_all); //프로세스 전체 배열인 plist에 대해 검사한다
			if (p->pid != 0 && p->state == PROC_RUN) { //만약 프로세스가 0번이 아니고 run 상태면
				if (found == false)  //found flag가 false로 설정
					found = true; //이를 true로 설정하고
				else 
					printk(", "); //이미 true이면 쉼표를 출력
				
				printk("#= %d p= %d c= %d u= %d ", p->pid, p->priority, p->time_slice, p->time_used); //pid, priority,time_slice, time_used 출력
			}
		}

		/*for (idx = 0 ; idx < RQ_NQS ; idx++) {
			for (elem = list_begin(&runq[idx]); elem != list_end(&runq[idx]); elem = list_next(elem)) { 
				p = list_entry(elem, struct process, elem_all); //프로세스 전체 배열인 plist에 대해 검사한다
				if (p->pid != 0 && p->state == PROC_RUN) { //만약 프로세스가 0번이 아니고 run 상태면
					if (found == false)  //found flag가 false로 설정
						found = true; //이를 true로 설정하고
					 
					else 
						printk(", "); //이미 true이면 쉼표를 출력
					
					printk("#= %d p= %d c= %d u= %d ", p->pid, p->priority, p->time_slice, p->time_used); //pid, priority,time_slice, time_used 출력
				}
			}
			
		}*/

		printk("\n"); 
		printk("Selected # = %d\n", next->pid); //선택된 다음 프로세스 번호를 출력

	}

	cur_process->time_slice = 0;

	switch_process(cur, next); //프로세스 스위칭 (스위칭 동안에는 인터럽트 핸들러가 발생해선 안됨)
	intr_enable(); //인터럽트 활성화
	
	return ;
	
}


