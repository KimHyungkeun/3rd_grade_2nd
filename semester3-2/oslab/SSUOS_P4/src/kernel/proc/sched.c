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
		//if(list_size(&runq[i]) == 0) continue;

		for (elem = list_begin(&runq[idx]); elem != list_end(&runq[idx]); elem = list_next(elem)) {
			struct process *p = list_entry(elem, struct process, elem_stat);

			if (p->state == PROC_RUN) {
				return p;
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
	

	/* You shoud modify this function.... */
	intr_disable();
	proc_wake();

	if (cur_process->state == PROC_STOP)
		printk("Proc %d I/O at %d\n", cur_process->pid, cur_process->time_used);

	if (cur_process->pid != 0) 
		next = idle_process;
	
	else 
		next = get_next_proc();
	
	cur = cur_process;
	cur_process = next;

	if (next->pid != 0) {

		for (elem = list_begin(&plist); elem != list_end(&plist); elem = list_next(elem)) {
			p = list_entry(elem, struct process, elem_all);
			if (p->pid != 0 && p->state == PROC_RUN) {
				if (found == false) {
					found = true;
				} else {
					printk(", ");
				}
				printk("#= %d p= %d ", p->pid, p->priority);
				printk("c= %d u= %d", p->time_slice, p->time_used);
			}
		}

		printk("\n");
		printk("Selected # = %d\n", next->pid);
		
	}

	cur_process->time_slice = 0;

	switch_process(cur, next);
	intr_enable();
	
	return ;
	
}


