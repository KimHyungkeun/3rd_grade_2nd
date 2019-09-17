#include <filesys/inode.h>
#include <proc/proc.h>
#include <device/console.h>
#include <mem/palloc.h>


int file_open(struct inode *inode, int flags, int mode)
{
	int fd;
	struct ssufile **file_cursor = cur_process->file;

	for(fd = 0; fd < NR_FILEDES; fd++)
	{
		if(file_cursor[fd] == NULL)
		{
			if( (file_cursor[fd] = (struct ssufile *)palloc_get_page()) == NULL)
				return -1;
			break;
		}	
	}
	
	inode->sn_refcount++;

	file_cursor[fd]->inode = inode;
	file_cursor[fd]->pos = 0;


	if(flags & O_APPEND){
		file_cursor[fd]->pos = file_cursor[fd]->inode->sn_size; //O_APPEND 플래그가 존재하면 offset 위치를 파일의 끝으로 보낸다.
	}

	else if(flags & O_TRUNC){
		file_cursor[fd]->inode->sn_size = 0; //O_TRUNC 플래그가 존재하면 파일크기를 0으로 다시 만든다
	}

	file_cursor[fd]->flags = flags;
	file_cursor[fd]->unused = 0;

	return fd;
}

int file_write(struct inode *inode, size_t offset, void *buf, size_t len)
{
	return inode_write(inode, offset, buf, len);
}

int file_read(struct inode *inode, size_t offset, void *buf, size_t len)
{
	return inode_read(inode, offset, buf, len);
}
