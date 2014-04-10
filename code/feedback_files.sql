/*
ALTER TABLE CBLUE.FEEDBACK_FILES
 DROP PRIMARY KEY CASCADE;

DROP TABLE CBLUE.FEEDBACK_FILES CASCADE CONSTRAINTS;
*/
CREATE TABLE CBLUE.FEEDBACK_FILES
(
  ID                  NUMBER                    NOT NULL,
  ROW_VERSION_NUMBER  NUMBER,
  COMMENT_ID          NUMBER                    NOT NULL,
  FILE_NAME           VARCHAR2(512 BYTE),
  FILE_MIMETYPE       VARCHAR2(512 BYTE),
  FILE_CHARSET        VARCHAR2(512 BYTE),
  FILE_LASTUPD        TIMESTAMP(6) WITH LOCAL TIME ZONE,
  FILE_BLOB           BLOB,
  TAGS                VARCHAR2(4000 BYTE),
  CREATED             TIMESTAMP(6) WITH LOCAL TIME ZONE NOT NULL,
  CREATED_BY          VARCHAR2(255 BYTE)        NOT NULL,
  UPDATED             TIMESTAMP(6) WITH LOCAL TIME ZONE,
  UPDATED_BY          VARCHAR2(255 BYTE)
)
LOB (FILE_BLOB) STORE AS (
  TABLESPACE APEX_2725922629710405
  ENABLE       STORAGE IN ROW
  CHUNK       8192
  RETENTION
  NOCACHE
  LOGGING
      STORAGE    (
                  INITIAL          64K
                  NEXT             1M
                  MINEXTENTS       1
                  MAXEXTENTS       UNLIMITED
                  PCTINCREASE      0
                  BUFFER_POOL      DEFAULT
                  FLASH_CACHE      DEFAULT
                  CELL_FLASH_CACHE DEFAULT
                 ))
TABLESPACE APEX_2725922629710405
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


CREATE INDEX CBLUE.FEEDBACK_FILES_01 ON CBLUE.FEEDBACK_FILES
(COMMENT_ID)
LOGGING
TABLESPACE APEX_2725922629710405
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOPARALLEL;


CREATE UNIQUE INDEX CBLUE.FEEDBACK_FILES_PK ON CBLUE.FEEDBACK_FILES
(ID)
;


CREATE OR REPLACE TRIGGER CBLUE.biu_feedback_files
   before insert or update ON CBLUE.FEEDBACK_FILES
   for each row
begin
  if (inserting or updating) and nvl(dbms_lob.getlength(:new.file_blob),0) > 15728640 then
    raise_application_error(-20000, 'The size of the uploaded file was over 15MB. Please upload a smaller file.');
  end if;
  if inserting then
    if :NEW.ID is null then
      select to_number(sys_guid(),'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
        into :new.id
        from dual;
    end if;
    :NEW.CREATED := localtimestamp;
    :NEW.CREATED_BY := nvl(v('APP_USER'),USER);
    :NEW.UPDATED := localtimestamp;
    :NEW.UPDATED_BY := nvl(v('APP_USER'),USER);
    :new.row_version_number := 1;
  end if;
  if updating then
    :NEW.UPDATED := localtimestamp;
    :NEW.UPDATED_BY := nvl(v('APP_USER'),USER);
    :new.row_version_number := nvl(:new.row_version_number,0) + 1;
  end if;
end;
/


ALTER TABLE CBLUE.FEEDBACK_FILES ADD (
  CONSTRAINT FEEDBACK_FILES_PK
  PRIMARY KEY
  (ID)
  USING INDEX CBLUE.FEEDBACK_FILES_PK
  ENABLE VALIDATE);

ALTER TABLE CBLUE.FEEDBACK_FILES ADD (
  CONSTRAINT FEEDBACK_FILES_COMM_FK 
  FOREIGN KEY (COMMENT_ID) 
  REFERENCES CBLUE.FEEDBACK_COMMENTS (ID)
  ON DELETE CASCADE
  ENABLE VALIDATE);
