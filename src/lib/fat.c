/*
 * Copyright (C) 2018 bzt (bztsrc@github)
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 */

#include "sd.h"
#include "fat.h"
#include "uart.h"
#include "vfb.h"
#include "syscall.h"


// add memory compare
int _bzt_memcmp(void *s1, void *s2, int n)
{
    unsigned char *a=s1,*b=s2;
    while(n-->0){ if(*a!=*b) { return *a-*b; } a++; b++; }
    return 0;
}

static u32 _PARTITION_LBA = 0;


bpb_t* fat_get_partition(void) {
    // allocate a sector on kernel heap
    u8* mbr = syscall_kmalloc(FAT32_SECTOR_SIZE);

    // attempt read of sector 0, Boot Record
    int read_bytes = sd_readblock(0, mbr, 1);
    if(read_bytes > FAT32_SECTOR_SIZE) {
        syscall_kfree((void*)mbr);
        return NULL;
    }

    // if read was succesfull
    if(read_bytes) {
        // check MBR signature
        if(mbr[0x1FE]!=0x55 || mbr[0x1FF]!=0xAA) {
            uart_send_string("ERROR: fat_get_bpb: Invalid signature\n\r");
            syscall_kfree((void*)mbr);
            return NULL;
        }

        // check partition type
        if(mbr[0x1C2] != 0xE /*FAT16 LBA*/ && mbr[0x1C2] != 0xC /*FAT32 LBA*/) {
            uart_send_string("ERROR: fat_get_bpb: Wrong partition type\n\r");
            syscall_kfree((void*)mbr);
            return NULL;
        }

        // read boot record over MBR
        _PARTITION_LBA = mbr[0x1C6] + (mbr[0x1C7]<<8) + (mbr[0x1C8]<<16) + (mbr[0x1C9]<<24);
        if(!sd_readblock(_PARTITION_LBA, mbr, 1)) {
            uart_send_string("ERROR: fat_get_bpb: Unable to read boot record\n\r");
            syscall_kfree((void*)mbr);
            return NULL;
        }

        // read bpb and check FS type
        bpb_t* bpb = (bpb_t*) mbr;
        if(!(bpb->fst[0]  =='F' && bpb->fst[1]  =='A' && bpb->fst[2]  =='T') &&
           !(bpb->fst2[0] =='F' && bpb->fst2[1] =='A' && bpb->fst2[2] =='T')) {
            uart_send_string("ERROR: fat_get_bpb: Unknown file system type\n\r");
            syscall_kfree((void*)mbr);
            return NULL;
        }

        return bpb;
    }

    return NULL;
}


u32 fat_get_cluster(char *file_name, bpb_t* bpb) {
    // allocate a sector
    u8* sector = (u8*)syscall_kmalloc(FAT32_SECTOR_SIZE);
    fatdir_t* dir = (fatdir_t*)sector;
    u32 root_lba, s;

    // find the root directory's LBA
    // 0. check if FAT16 or FAT32
    // 1. multiply by number of FATs
    // 2. add number of reserved logical sector
    root_lba = ((bpb->spf16 ? bpb -> spf16 : bpb -> spf32) * bpb->nf) + bpb -> rsc;

    // calculate number of root entries
    s = (bpb->nr0 + (bpb->nr1 << 8)) * sizeof(fatdir_t);

    // check if not FAT16
    if(bpb -> spf16 == 0) {
        // adjust for FAT32
        root_lba += (bpb -> rc - 2) * bpb -> spc;
    }

    // add partition LBA
    root_lba += _PARTITION_LBA;

    // load the root directory
    if(sd_readblock(root_lba, sector, s/FAT32_SECTOR_SIZE+1)) {
        // iterate on each entry and check if it's the one we're looking for
        for(;dir -> name[0] != 0; dir++) {
            // is it a valid entry?
            if(dir -> name[0] == 0xE5 || dir -> attr[0] == 0xF) continue;

            // filename match?
            if(!_bzt_memcmp(dir->name, file_name, 11)) {
                // free sector
                syscall_kfree((void*)sector);
                // return cluster
                return ((u32)dir -> ch) << 16 | dir -> cl;
            }
        }
        uart_send_string("ERROR: fat_get_cluster: File not found\n\r");
    } else {
        uart_send_string("ERROR: fat_get_cluster: Unable to load root directory\n\r");
    }

    syscall_kfree((void*)sector);
    return 0;
}


void fat_list_dir(bpb_t* bpb) {
    // allocate a sector
    u8* sector = (u8*)syscall_kmalloc(FAT32_SECTOR_SIZE);
    fatdir_t* dir = (fatdir_t*)sector;
    u32 root_lba, s;

    // find the root directory's LBA
    // 0. check if FAT16 or FAT32
    // 1. multiply by number of FATs
    // 2. add number of reserved logical sector
    root_lba = ((bpb->spf16 ? bpb -> spf16 : bpb -> spf32) * bpb->nf) + bpb -> rsc;

    // calculate number of root entries
    s = (bpb->nr0 + (bpb->nr1 << 8)) * sizeof(fatdir_t);

    // check if not FAT16
    if(bpb -> spf16 == 0) {
        // adjust for FAT32
        root_lba += (bpb -> rc - 2) * bpb -> spc;
    }

    // add partition LBA
    root_lba += _PARTITION_LBA;

    // load the root directory
    if(sd_readblock(root_lba, sector, s/FAT32_SECTOR_SIZE+1)) {
        // iterate on each entry
        printf("listing FAT entries\n");
        for(;dir -> name[0] != 0; dir++) {
            // is it a valid entry?
            // if(dir -> name[0] == 0xE5 || dir -> attr[0] == 0xF) continue;
            if(dir->name[0]==0x2E || dir->name[0]==0xE5 || dir->attr[0]==0xF || dir->name[0]==0x05) continue;

            // post attribute printing
            dir -> attr[0] = 0;
            printf(" name: "); printf(dir -> name);
            printf(" - cluster: %x", (u32)(dir->ch)<<16|dir->cl);
            printf(" - size: %x", (u32)dir -> size);
            printf("\n");
        }
        syscall_kfree((void*)sector);
        return;
    } else {
        uart_send_string("ERROR: fat_get_cluster: Unable to load root directory\n\r");
    }

    syscall_kfree((void*)sector);
    return;
}


u8* fat_read_file(u32 cluster, bpb_t* bpb) {

    // FAT tables
    u32* fat32=(u32*)(bpb -> rsc*FAT32_SECTOR_SIZE);
    u16 *fat16=(u16*)fat32;

    // find the LBA of the first data sector
    u32 data_lba, s;
    data_lba = ((bpb->spf16?bpb->spf16:bpb->spf32)*bpb->nf)+bpb->rsc;
    s = (bpb->nr0 + (bpb->nr1 << 8)) * sizeof(fatdir_t);
    if(bpb -> spf16 > 0) {
        // adjust for FAT16
        data_lba += (s+FAT32_SECTOR_SIZE-1) >> 9;
    }

    // add partition LBA
    data_lba += _PARTITION_LBA;

    // dump important properties
    uart_send_string("FAT Bytes per Sector: ");
    uart_send_hex(bpb->bps0 + (bpb->bps1 << 8));
    uart_send_string("\n\rFAT Sectors per Cluster: ");
    uart_send_hex(bpb->spc);
    uart_send_string("\n\rFAT Number of FAT: ");
    uart_send_hex(bpb->nf);
    uart_send_string("\n\rFAT Sectors per FAT: ");
    uart_send_hex((bpb->spf16?bpb->spf16:bpb->spf32));
    uart_send_string("\n\rFAT Reserved Sectors Count: ");
    uart_send_hex(bpb->rsc);
    uart_send_string("\n\rFAT First data sector: ");
    uart_send_hex(data_lba);
    uart_send_string("\n\r");

    // load FAT table
    s = sd_readblock(_PARTITION_LBA+1,(u8*)0x11000000, (bpb->spf16?bpb->spf16:bpb->spf32)+bpb->rsc);
    uart_send_string("sd_readblock: ");
    uart_send_hex(s);
    uart_clrf();

    // prepare memory for file read
    u8* data = (u8*)syscall_kmalloc(FAT32_SECTOR_SIZE);
    u8* ptr = data;

    u32 total_read = 0;

    // iterate cluster chain
    while(cluster > 1 && cluster < 0xFFF8) {
        // load all sectors in a cluster
        total_read += sd_readblock((cluster - 2) * bpb -> spc + data_lba, ptr, bpb -> spc);

        // move pointer, sector per cluster * bytes per sector
        ptr += bpb -> spc * (bpb -> bps0 + (bpb -> bps1 << 8));

        // get the next cluster in chain
        cluster = bpb -> spf16 > 0 ? fat16[cluster] : fat32[cluster];
    }

    uart_send_string("fat_read_file: ");
    uart_send_hex(total_read);
    uart_clrf();

    return data;
}
