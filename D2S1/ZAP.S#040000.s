 SBTL 'Z A P -- DISK UPDATE UTILITY'
 ORG $900
 SKP 1
***********************************************************
*                                                         *
* ZAP: THIS PROGRAM WILL ALLOW ITS USER TO READ/WRITE     *
*      INDIVIDUAL SECTORS FROM/TO THE DISKETTE            *
*                                                         *
* INPUT: $02 = TRACK TO BE READ                           *
*        $03 = SECTOR TO BE READ/WRITTEN                  *
*        $04 = $01 - READ SECTOR                          *
*              $02 - WRITE SECTOR                         *
*        $800 = ADDRESS OF SECTOR DATA BUFFER             *
*                                                         *
* ENTRY POINT: $900                                       *
*                                                         *
* PROGRAMMER: DON D WORTH 2/15/81                         *
*                                                         *
***********************************************************
 SKP 2
BELL EQU $87 BELL CHARACTER
 SKP 1
*       ZPAGE DEFINITIONS
 SKP 1
PTR EQU $0 WORK POINTER
TRACK EQU $2 TRACK TO BE READ/WRITTEN
SECTOR EQU $3 SECTOR TO BE READ/WRITTEN
OPER EQU $4 OPERATION TO BE PERFORMED
READ EQU 1    READ OPERATION
WRITE EQU 2    WRITE OPERATION
A1L EQU $3C MONITOR POINTER
A2L EQU $3E MONITOR POINTER
PREG EQU $48 MONITOR STATUS REGISTER
 SKP 1
*       OTHER ADDRESSES
 SKP 1
BUFFER EQU $800 SECTOR DATA BUFFER
LOCRPL EQU $3E3 LOCATE RWTS PARMLIST SUBRTN
RWTS EQU $3D9 RWTS SUBROUTINE
COUT EQU $FDED PRINT ONE CHAR SUBROUTINE
PRBYTE EQU $FDDA PRINT ONE HEX BYTE SUBRTN
XAM EQU $FDB3 MONITOR HEX DUMP SUBRTN
 SKP 1
*       RWTS PARMLIST DEFINITION
 SKP 1
 DSECT
RPLIOB DS 1 IOB TYPE ($01)
RPLSLT DS 1 SLOT*16
RPLDRV DS 1 DRIVE
RPLVOL DS 1 VOLUME
RPLTRK DS 1 TRACK
RPLSEC DS 1 SECTOR
RPLDCT DS 2 ADDRESS OF DCT
RPLBUF DS 2 ADDRESS OF BUFFER
RPLSIZ DS 2 SECTOR SIZE
RPLCMD DS 1 COMMAND CODE
RPLCNL EQU $00    NULL COMMAND
RPLCRD EQU $01    READ COMMAND
RPLCWR EQU $02    WRITE COMMAND
RPLCFM EQU $04    FORMAT COMMAND
RPLRCD DS 1 RETURN CODE
RPLRWP EQU $10    WRITE PROTECTED
RPLRVM EQU $20    VOLUME MISMATCH
RPLRDE EQU $40    DRIVE ERROR
RPLRRE EQU $80    READ ERROR
RPLTVL DS 1 TRUE VOLUME
RPLPSL DS 1 PREVIOUS SLOT
RPLPDR DS 1 PREVIOUS DRIVE
 DEND
 SKP 2
*       FILL IN RWTS LIST
 SKP 1
ZAP JSR LOCRPL LOCATE RWTS PARMLIST
 STY PTR AND SAVE POINTER
 STA PTR+1
 SKP 1
 LDA TRACK GET TRACK TO READ/WRITE
 LDY #RPLTRK STORE IN RWTS LIST
 STA (PTR),Y
 SKP 1
 LDA SECTOR GET SECTOR TO READ/WRITE
 CMP #16 BIGGER THAN 16 SECTORS?
 BCC SOK NO
 LDA #0
 STA SECTOR YES, PUT IT BACK TO ZERO 
SOK LDY #RPLSEC
 STA (PTR),Y STORE IN RWTS LIST
 SKP 1
 LDY #RPLBUF 
 LDA #>BUFFER STORE BUFFER PTR IN LIST
 STA (PTR),Y
 INY
 LDA #<BUFFER
 STA (PTR),Y
 SKP 1
 LDA OPER GET COMMAND CODE
 LDY #RPLCMD AND STORE IN LIST
 STA (PTR),Y
 SKP 1
 LDA #0 ANY VOLUME WILL DO
 LDY #RPLVOL 
 STA (PTR),Y
 SKP 1
*       NOW CALL RWTS TO READ/WRITE THE SECTOR
 SKP 1
 JSR LOCRPL RELOAD POINTER TO PARMS
 JSR RWTS CALL RWTS
 LDA #0
 STA PREG FIX P REG SO DOS IS HAPPY
 BCC EXIT ALL IS WELL
 PAGE
*       ERROR OCCURED, PRINT "RC=XX"
 SKP 1
 LDA #BELL BEEP THE SPEAKER
 JSR COUT
 LDA #'R PRINT THE "RC="
 JSR COUT 
 LDA #'C
 JSR COUT 
 LDA #'=
 JSR COUT 
 LDY #RPLRCD 
 LDA (PTR),Y GET RWTS RETURN CODE 
 JSR PRBYTE PRINT RETURN CODE IN HEX
 SKP 1
*       WHEN FINISHED, DUMP SOME OF SECTOR IN HEX
 SKP 1
EXIT LDA #>BUFFER DUMP 800.8B7
 STA A1L
 LDA #<BUFFER
 STA A1L+1
 LDA #>BUFFER+$AF
 STA A2L
 LDA #<BUFFER+$AF
 STA A2L+1
 JMP XAM EXIT VIA HEX DISPLAY
\x00\x00
 JMP XAM EXIT VIA HEX DISPLAY
