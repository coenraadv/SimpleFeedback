ALTER TABLE CBLUE.FEEDBACK_COMMENTS
 DROP PRIMARY KEY CASCADE;

DROP TABLE CBLUE.FEEDBACK_COMMENTS CASCADE CONSTRAINTS;

CREATE TABLE CBLUE.FEEDBACK_COMMENTS
(
  ID                  NUMBER                    NOT NULL,
  ROW_VERSION_NUMBER  NUMBER                    NOT NULL,
  APPLICATION_ID      NUMBER                    NOT NULL,
  PAGE_ID             NUMBER                    ,
  TYPE_ID             NUMBER                    ,
  FEEDBACK_TYPE       VARCHAR2(255 BYTE)        NOT NULL,
  EMAIL               VARCHAR2(255 BYTE)        ,
  REFERER             VARCHAR2(1000 BYTE)       ,
  BROWSER             VARCHAR2(1000 BYTE)       ,
  ROW_KEY             VARCHAR2(30 BYTE),
  COMPONENT_ID        NUMBER,
  COMPONENT           VARCHAR2(30 BYTE),
  MODULE_ID           NUMBER,
  FEEDBACK            VARCHAR2(4000 BYTE),
  CONTACT_YN          VARCHAR2(1 BYTE)          DEFAULT 'Y',
  TAGS                VARCHAR2(4000 BYTE),
  COMPONENT_NAME      VARCHAR2(100 BYTE),
  MODULE_NAME         VARCHAR2(100 BYTE),
  STATUS              VARCHAR2(10 BYTE),
  NOTES               VARCHAR2(4000 CHAR),
  REFERENCE_TYPE      VARCHAR2(50 CHAR),
  REFERENCE_ID        NUMBER,
  CREATED             TIMESTAMP(6) WITH LOCAL TIME ZONE,
  CREATED_BY          VARCHAR2(255 BYTE),
  UPDATED             TIMESTAMP(6) WITH LOCAL TIME ZONE,
  UPDATED_BY          VARCHAR2(255 BYTE)
)
;





CREATE UNIQUE INDEX CBLUE.FEEDBACK_COMMENTS_PK ON CBLUE.FEEDBACK_COMMENTS
(ID)
;


CREATE OR REPLACE TRIGGER CBLUE.biu_feedback_comments
   before insert or update ON CBLUE.FEEDBACK_COMMENTS             
   for each row
DECLARE
  l_id number;   
begin  
   if :new."ID" is null or :new.row_key is null then
     select feedback_comments_seq.nextval into l_id from dual;
   end if;
   if :new."ID" is null then
     --select to_number(sys_guid(),'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX') into :new.id from dual;
       :new.id := l_id;
   end if;
   if :new.row_key is null then
       --select feedback_fw.compress_int(feedback_comment_seq.nextval) into :new.row_key from dual;
       select feedback_fw.compress_int(l_id) into :new.row_key from dual;
   end if;
   if inserting then
       :new.created := localtimestamp;
       :new.created_by := nvl(wwv_flow.g_user,user);
       :new.row_version_number := 1;
   elsif updating then
       :new.row_version_number := nvl(:old.row_version_number,1) + 1;
   end if;
   if inserting or updating then
       :new.updated := localtimestamp;
       :new.updated_by := nvl(wwv_flow.g_user,user);
   end if;
   /*
   if inserting then
       eba_feedback_fw.tag_sync(
         p_new_tags      => :new.tags,
         p_old_tags      => null,
         p_content_type  => 'FEEDBACK',
         p_content_id    => :new.id );
   elsif updating then
       :new.row_version_number := nvl(:old.row_version_number,1) + 1;
       eba_feedback_fw.tag_sync(
         p_new_tags      => :new.tags,
         p_old_tags      => :old.tags,
         p_content_type  => 'FEEDBACK',
         p_content_id    => :new.id );
   end if;
   if inserting then
       for c1 in (select name from feedback_modules where id = :New.module_id) loop
          :new.module_name := c1.name;
       end loop;
       for c1 in (select name from feedback_components where id = :New.component_id) loop
          :new.component_name := c1.name;
       end loop;
    end if;
   */
end;
/

/*
CREATE OR REPLACE TRIGGER CBLUE.BD_feedback_comments
    before delete ON CBLUE.FEEDBACK_COMMENTS
    for each row
begin
    eba_feedback_fw.tag_sync(
        p_new_tags      => null,
        p_old_tags      => :old.tags,
        p_content_type  => 'FEEDBACK',
        p_content_id    => :old.id );
end;
/
*/

ALTER TABLE CBLUE.FEEDBACK_COMMENTS ADD (
  CONSTRAINT FEEDBACK_COMMENTS_PK
  PRIMARY KEY
  (ID)
  USING INDEX CBLUE.FEEDBACK_COMMENTS_PK
  ENABLE VALIDATE);

/*
ALTER TABLE CBLUE.FEEDBACK_COMMENTS ADD (
  CONSTRAINT FEEDBACK_COMM_COMP_FK 
  FOREIGN KEY (COMPONENT_ID) 
  REFERENCES CBLUE.FEEDBACK_COMPONENTS (ID)
  ON DELETE SET NULL
  ENABLE VALIDATE,
  CONSTRAINT FEEDBACK_COMM_MODULE_FK 
  FOREIGN KEY (MODULE_ID) 
  REFERENCES CBLUE.FEEDBACK_MODULES (ID)
  ON DELETE SET NULL
  ENABLE VALIDATE,
  CONSTRAINT FEEDBACK_COMM_TYPE_FK 
  FOREIGN KEY (TYPE_ID) 
  REFERENCES CBLUE.FEEDBACK_TYPES (ID)
  ENABLE VALIDATE));
*/