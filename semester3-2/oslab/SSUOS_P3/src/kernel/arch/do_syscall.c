#include <proc/sched.h>
#include <proc/proc.h>
#include <device/device.h>
#include <interrupt.h>
#include <device/kbd.h>
#include <filesys/file.h>

pid_t do_fork(proc_func func, void* aux1, void* aux2)
{
	pid_t pid;
	struct proc_option opt;

	opt.priority = cur_process-> priority;
	pid = proc_create(func, &opt, aux1, aux2);

	return pid;
}

void do_exit(int status)
{
	cur_process->exit_status = status; 	//종료 상태 저장
	proc_free();						//프로세스 자원 해제
	do_sched_on_return();				//인터럽트 종료시 스케줄링
}

pid_t do_wait(int *status)
{
	while(cur_process->child_pid != -1)
		schedule();
	//SSUMUST : schedule 제거.

	int pid = cur_process->child_pid;
	cur_process->child_pid = -1;

	extern struct process procs[];
	procs[pid].state = PROC_UNUSED;

	if(!status)
		*status = procs[pid].exit_status;

	return pid;
}

void do_shutdown(void)
{
	dev_shutdown();
	return;
}

int do_ssuread(void)
{
	return kbd_read_char();
}

int do_open(const char *pathname, int flags)
{
	struct inode *inode;
	struct ssufile **file_cursor = cur_process->file;
	int fd;

	for(fd = 0; fd < NR_FILEDES; fd++)
		if(file_cursor[fd] == NULL) break;

	if (fd == NR_FILEDES)
		return -1;

	if ( (inode = inode_open(pathname, flags)) == NULL)
		return -1;
	
	if (inode->sn_type == SSU_TYPE_DIR)
		return -1;


	fd = file_open(inode,flags,0);

	
	return fd;
}

int do_read(int fd, char *buf, int len)
{
	return generic_read(fd, (void *)buf, len);
}
int do_write(int fd, const char *buf, int len)
{
	return generic_write(fd, (void *)buf, len);
}

int do_fcntl(int fd, int cmd, long arg)
{
	int flag = -1;
	struct ssufile **file_cursor = cur_process->file;
	int new_fd; //새로운 파일디스크립터가 복사될 경우 이 변수를 사용


	if (cmd & F_DUPFD){
		
		for(new_fd = arg; new_fd <= NR_FILEDES; new_fd++) { //할당가능한 파일디스크립터 검색
			if(file_cursor[new_fd] == NULL){ //만약 비어있는 파일디스크립터가 존재하면
				file_cursor[new_fd] = file_cursor[fd]; //현재의 디스크립터를 새로운 디스크립터로 복사
				break;
			}
		}
		
		if (new_fd > NR_FILEDES) //만약 해당 파일디스크립터가 한도갯수를 초과한 경우
			return -1; //에러처리한다
		
		return new_fd; //새로 할당된 파일디스크립터를 리턴시킨다.

	}
	else if (cmd & F_GETFL){ //cmd가 F_GETFL 
		return file_cursor[fd]->flags; //open했을시 담겨져있던 플래그 상태를 리턴
	}
	else if(cmd & F_SETFL){ //cmd가 F_SETFL
		
		if ((arg & O_APPEND) != O_APPEND) { //만약 플래그에 O_APPEND가 들어있지 아니하면
			return flag; //에러로 처리
		}

		file_cursor[fd]->flags = arg; // O_APPEND 플래그상태를 넣는다
		return file_cursor[fd]->flags ; // O_APPEND가 포함된 플래그를 리턴
	}
	else{
		
		return flag; //아무것도 아니면 에러처리
		
		
	}

}
