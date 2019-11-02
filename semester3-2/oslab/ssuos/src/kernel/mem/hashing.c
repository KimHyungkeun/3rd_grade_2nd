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
    for (i = 0 ; i < CAPACITY ; i++) {
        for (j = 0 ; j < SLOT_NUM ; j++) {
            hash_table.top_buckets[i].token[j] = 0;
            hash_table.top_buckets[i].slot[j].key = 0;
            hash_table.top_buckets[i].slot[j].value = 0;
        }
    }

    for (i = 0 ; i < CAPACITY/2 ; i++) {
        for (j = 0 ; j < SLOT_NUM ; j++) {
            hash_table.bottom_buckets[i].token[j] = 0;
            hash_table.bottom_buckets[i].slot[j].key = 0;
            hash_table.bottom_buckets[i].slot[j].value = 0;
            
        }
    }
 
}

void insert_hash_table(void* pages, size_t page_idx) {
    
    int i, full_top = 0;
    uint32_t hash1_idx, hash2_idx; 
    uint32_t idx, value, key;
    uint32_t *virtual_address = (uint32_t *)pages;

    // idx : hash value (F_IDX or S_IDX)
    // value : Real_address(Use VH_TO_RH)
    // key : page_index

    hash1_idx = F_IDX(virtual_address, CAPACITY);
    hash2_idx = S_IDX(virtual_address, CAPACITY);

    value = VH_TO_RH(virtual_address);
    key = page_idx;

    for (i = 0 ; i < SLOT_NUM ; i++) {
        if ( hash_table.top_buckets[hash1_idx].token[i] == 0 ) {
            hash_table.top_buckets[hash1_idx].token[i] = 1;
            hash_table.top_buckets[hash1_idx].slot[i].key = key;
            hash_table.top_buckets[hash1_idx].slot[i].value = value;
            idx = hash1_idx;
            printk("hash value inserted in top level : idx : %d, key : %d, value : %x\n",idx,key,value);
            break;
        }

        else if ( hash_table.top_buckets[hash2_idx].token[i] == 0 ) {
            hash_table.top_buckets[hash2_idx].token[i] = 1;
            hash_table.top_buckets[hash2_idx].slot[i].key = key;
            hash_table.top_buckets[hash2_idx].slot[i].value = value;
            idx = hash2_idx;
            printk("hash value inserted in top level : idx : %d, key : %d, value : %x\n",idx,key,value);
            break;
        }

        else
            full_top++;
        
    }

    if( full_top == SLOT_NUM ) {
         for (i = 0 ; i < SLOT_NUM ; i++) {
             if ( hash_table.bottom_buckets[hash1_idx/2].token[i] == 0 ) {
                hash_table.bottom_buckets[hash1_idx/2].token[i] = 1;
                hash_table.bottom_buckets[hash1_idx/2].slot[i].key = key;
                hash_table.bottom_buckets[hash1_idx/2].slot[i].value = value;
                idx = hash1_idx/2;
                printk("hash value inserted in bottom level : idx : %d, key : %d, value : %x\n",idx,key,value);
                break;
            }

            else if ( hash_table.bottom_buckets[hash2_idx/2].token[i] == 0 ) {
                hash_table.bottom_buckets[hash2_idx/2].token[i] = 1;
                hash_table.bottom_buckets[hash2_idx/2].slot[i].key = key;
                hash_table.bottom_buckets[hash2_idx/2].slot[i].value = value;
                idx = hash2_idx/2;
                printk("hash value inserted in bottom level : idx : %d, key : %d, value : %x\n",idx,key,value);
                break;
            }
         }
    }
    
}

void delete_hash_table(void* pages, size_t page_idx) {
    
   int i, full_top = 0;;
   uint32_t hash1_idx, hash2_idx; 
   uint32_t idx, value, key;
   uint32_t *virtual_address = (uint32_t *)pages;

    // idx : hash value (F_IDX or S_IDX)
    // value : Real_address(VH_TO_RH)
    // key : page_index

    hash1_idx = F_IDX(virtual_address, CAPACITY);
    hash2_idx = S_IDX(virtual_address, CAPACITY);

    value = VH_TO_RH(virtual_address);
    key = page_idx;

    for (i = 0 ; i < SLOT_NUM ; i++) {
        if ( hash_table.top_buckets[hash1_idx].slot[i].key == key ) {
            hash_table.top_buckets[hash1_idx].token[i] = 0;
            idx = hash1_idx;
            break;
        }

        else if ( hash_table.top_buckets[hash2_idx].slot[i].key == key ) {
            hash_table.top_buckets[hash2_idx].token[i] = 0;
            idx = hash2_idx;
            break;
        }

        else
            full_top++;
    }

    if (full_top == SLOT_NUM) {
        for (i = 0 ; i < SLOT_NUM ; i++) {
            if ( hash_table.bottom_buckets[hash1_idx/2].slot[i].key == key ) {
                hash_table.bottom_buckets[hash1_idx/2].token[i] = 0;
                idx = hash1_idx/2;
                break;
            }

            else if ( hash_table.bottom_buckets[hash2_idx/2].slot[i].key == key ) {
                hash_table.bottom_buckets[hash2_idx/2].token[i] = 0;
                idx = hash2_idx/2;
                break;
            }

        }
    }

    if ( i == SLOT_NUM ) {
            return;
    }

    printk("hash value deleted : idx : %d, key : %d, value : %x\n",idx,key,value);

}