dw ;ven/smh&toad-web: services ;2016-04-03 09:30
 ;;24.0T1;File Manager;;under development;
 ;(c) 2013-6, Sam Habiel & Frederick D. S. Marshall
 ;($) funded by Sam Habiel & Frederick D. S. Marshall
 ;(l) See README.md.
 ;
 ;
 ; primary development history
 ;
 ; original author: Dr. Sam Habiel (smh)
 ; additional author: Frederick D. S. Marshall of VEN (toad)
 ; development organization: Vista Expertise Network (ven)
 ;
 ; 2013-10-25 ven/smh: previous work on routine DDWC001.
 ;
 ; 2013-12-18 ven/smh: "First commit of files"
 ; routine DDWC001 first published on Github.
 ;
 ; 2013-12-18 ven/smh: "comment out stray zshow for debugging"
 ; VALS: commented out ZSHOW "V":^KBANFDA.
 ; TEST, TEST2, ASSERT: label separator added after labels.
 ;
 ; 2014-02-03 ven/smh: "added fdapost to handle post /fileman/fda"
 ; FDAPOST: new procedure created. TEST: removed comment re bug from
 ; call to DECODE^VPRJSON.
 ;
 ; 2014-02-05 ven/smh: "more on filefda to make it prim and proper"
 ; FDAPOST: ensure uppercase flags, handle errors, improve return
 ; value.
 ;
 ; 2016-03-01/02 ven/toad: document history, catalog contents, to-do
 ; list, standardize subroutine header comments, convert language
 ; elements and variables to lowercase, tighten scope of locals to
 ; clarify subroutine structure. getFieldAttr: use $$JSN. create
 ; routine dw as copy of DDWC001, which is restored to 2014-02-05
 ; version (DDW namespace belongs to Paul Keltz text editor),
 ; passim.
 ; [note: so far, most testing is done from the javascript side.]
 ; Work-in-progress, not stable or tested. Use version 2014-02-05.
 ;
 ;
 ; contents
 ;
 ;   web service get fileman/dd/{fields} subroutines:
 ;
 ; DD: web service get fileman/dd/{fields} - dictionary
 ; getFieldAttr: return field-level attributes for a file
 ;
 ;   web service post fileman/vals subroutines:
 ;
 ; $$VALS: web service post fileman/vals - validate
 ; $$JSN = convert number from mumps format to javascript
 ;
 ;   web service post fileman/fda subroutines:
 ;
 ; $$FDAPOST: web service post fileman/fda - update
 ;
 ;   testing subroutines:
 ;
 ; TEST: test DD^dw, uses asserts
 ; TEST2: test $$VALS^dw, uses zwrites
 ; ASSERT: assertion procedure, throws mumps error
 ;
 ;
 ; to do
 ;
 ; finish first-pass refactoring
 ; break up big subroutines into smaller, testable subroutines
 ; create a new routine for each supported web service
 ;   e.g., dwdd for DD^dw, dwval for $$VALS^dw, etc.
 ; move tests to dwu
 ; convert tests to m-unit
 ; greatly expand unit-test coverage
 ; create new fileman web services
 ;
 ;
 ;
 ; web service get fileman/dd/{fields} subroutines
 ;
 ;
 ;
DD(RESULTS,ARGS) ; web service get fileman/dd/{fields} - dictionary
 ;ven/smh&toad;private;procedure;clean;silent;sac
 ; called by:
 ;   m-web-server
 ; calls:
 ;   $$UNKARGS^VPRJRUT = true if any argument is unknown
 ;   getFieldAttr: get file's field-level attributes
 ;   SETERROR^VPRJRUT: set error info into ^TMP("HTTPERR",$job)
 ;   ENCODE^VPRJSON: encode mumps array as json object
 ; input:
 ;   ARGS
 ; output:
 ;   RESULTS
 ; examples:
 ;   [develop examples]
 ;
 ; Supported fields format:
 ; -  file,field; file,field; etc...
 ; -  field can be field1:field2
 new RTN ; return array internally
 quit:$$UNKARGS^VPRJRUT(.ARGS,"fields")  ; Is any of these not passed?
 new DDWI for DDWI=1:1:$length(ARGS("fields"),";") do
 . new PAIR set PAIR=$piece(ARGS("fields"),";",DDWI)
 . new FILE set FILE=+$piece(PAIR,",")
 . new FIELD set FIELD=$piece(PAIR,",",2)
 . ;
 . if $length(FIELD,":")>1 do  quit
 . . new START set START=+$piece(FIELD,":") ; from JS
 . . new END set END=+$piece(FIELD,":",2) ; from JS
 . . if START>END do  ; swap START and END
 . . . new T set T=END
 . . . set END=START
 . . . set START=T
 . . . kill T
 . . if $data(^DD(FILE,START)) do
 . . . do getFieldAttr(.RTN,FILE,START)
 . . . quit
 . . ;
 . . new done set done=0
 . . new DDWCI set DDWCI=START
 . . for  do  quit:done
 . . . set DDWCI=$order(^DD(FILE,DDWCI))
 . . . set done=DDWCI>END
 . . . quit:done
 . . . set done='DDWCI
 . . . quit:done
 . . . do getFieldAttr(.RTN,FILE,DDWCI)
 . . . quit
 . . quit
 . ;
 . else  do
 . . set FIELD=+FIELD ; from JS
 . . if '$data(^DD(FILE,FIELD)) do  quit
 . . . do SETERROR^VPRJRUT(404,"File or field not found")
 . . . quit
 . . do getFieldAttr(.RTN,FILE,FIELD)
 . . quit
 . quit
 ;
 do ENCODE^VPRJSON($name(RTN),$name(RESULTS))
 ;
 quit  ; end of DD
 ;
 ;
getFieldAttr(return,filenumber,fieldnumber) ; return field level attributes for a file
 ;ven/smh&toad;private;procedure;clean;silent;sac
 ; called by:
 ;   DD
 ;   getFieldAttr (recursive)
 ; calls:
 ;   FIELDLST^DID: get a (sub)file's list of fields
 ;   FIELD^DID: get a field's attributes
 ;   $$JSN = reformat mumps number as json number
 ; input:
 ;   filenumber
 ;   fieldnumber
 ; output:
 ;   return
 ; examples:
 ;   [develop examples]
 ;
 ; input:
 ; filenumber = ien of file to inspect
 ; output:
 ; .return = output array, passed by refernce
 ;
 new attrList do FIELDLST^DID($name(attrList))
 new attrs set attrs=""
 new name set name=""
 ;
 ;TODO: simplify this.
 for  do  quit:name=""
 . set name=$order(attrList(name))
 . quit:name=""
 . set attrs=attrs_";"_name
 . quit
 set attrs=$extract(attrs,2,$length(attrs))
 ;
 new fieldAttr
 do FIELD^DID(filenumber,fieldnumber,"",attrs,$name(fieldAttr))
 ;
 ; is our field a multiple?
 if fieldAttr("MULTIPLE-VALUED") do  quit
 . new mreturn ; multiple return
 . new file set file=+fieldAttr("SPECIFIER") ; sub-file number
 . ;
 . new ddwci set ddwci=0
 . for  do  quit:'ddwci
 . . set ddwci=$order(^DD(file,ddwci))
 . . quit:'ddwci
 . . do getFieldAttr(.mreturn,file,ddwci)
 . . quit
 . ;
 . new cnt set cnt=0
 . new i set i=""
 . for  set i=$order(mreturn(i)) quit:i=""  do
 . . set cnt=cnt+1
 . . set filenumber=$$JSN(filenumber) ; javascript format
 . . set fieldnumber=$$JSN(fieldnumber) ; javascript format
 . . merge return(filenumber_","_fieldnumber,cnt,i)=mreturn(i)
 . . quit
 . quit
 ;
 ; loop and put our data in output array.
 ;
 set filenumber=$$JSN(filenumber) ; javascript format
 set fieldnumber=$$JSN(fieldnumber) ; javascript format
 ;
 new attrName set attrName=""
 for  do  quit:attrName=""
 . set attrName=$o(fieldAttr(attrName))
 . quit:attrName=""
 . ;
 . ; Multiples... (description and technical description) dd elements.
 . if fieldAttr(attrName)=$name(fieldAttr(attrName)) do
 . . set filenumber=$$JSN(filenumber) ; javascript format
 . . set fieldnumber=$$JSN(fieldnumber) ; javascript format
 . . kill return(filenumber_","_fieldnumber,attrName) ; remove top level node for JSON formatter
 . . new i set i=0
 . . for  do  quit:'i
 . . . set i=$order(fieldAttr(attrName,i))
 . . . quit:'i
 . . . set return(filenumber_","_fieldnumber,attrName,i)=fieldAttr(attrName,i)
 . . . quit
 . . quit
 . ;
 . ; Singles
 . else  do
 . . set return(filenumber_","_fieldnumber,attrName)=fieldAttr(attrName)
 . . quit
 . quit
 ;
 quit  ; end of getFieldAttr
 ;
 ;
 ; an important but uncallable code fragment:
 ;
 ;
 set RESULTS=$$GET1^DIQ(FILE,IENS,FIELD,,$name(^TMP($job))) ; double trouble.
 if $data(^TMP("DIERR",$job)) do  quit
 . do SETERROR^VPRJRUT(404,"File or field not found")
 . quit
 ; if results is a regular field, that's the value we will get.
 ; if results is a WP field, RESULTS becomes the global ^TMP($job).
 if $data(^TMP($job)) do
 . do ADDCRLF^VPRJRUT(.RESULTS) ; crlf the result
 . quit
 ;
 quit  ; end of code fragment
 ;
 ;
 ;
 ; web service post fileman/vals subroutines
 ;
 ;
 ;
VALS(args,body,result) ; web service post fileman/vals - validate
 ;ven/smh&toad;private;procedure;clean;silent;sac
 ; called by:
 ;   m-web-server
 ; calls:
 ;   DECODE^VPRJSON: decode json object into mumps array
 ;   VALS^DIE: fileman validator: validate field values
 ;   $$JSN = convert number from mumps format to javascript
 ;   ENCODE^VPRJSON: encode mumps array as json object
 ; input:
 ;   args = I don't know; it's not used
 ;  .body = array with serialized json object
 ; output:
 ;   result = array with serialized json object
 ; examples:
 ;   [develop examples]
 ;
 ; step 1: decode json object into input array
 ;
 new ddpfda ; array to receive mumps representation of object
 do
 . new ddjson merge ddjson=body ; array with serialized json object
 . ;
 . ; ^KBANFDA("V",7)="ddpfda(2,1,""dd"")=.01"
 . ; ^KBANFDA("V",8)="ddpfda(2,1,""dd"",""\s"")="""""
 . ; ^KBANFDA("V",9)="ddpfda(2,1,""ien"")=""+1,"""
 . ; ^KBANFDA("V",10)="ddpfda(2,1,""value"")=""abc"""
 . ;
 . new ddperr ; array to receive error messages
 . ; to do: ddperr gives you an error now when there isn't one
 . ;
 . ; set json object into array:
 . do DECODE^VPRJSON($name(ddjson),$name(ddpfda),$name(ddperr))
 . quit
 ;
 ; step 2: build filer data array
 ;
 new ddffda ; filer data array, to map values to fields in files
 do
 . new file set file="" ; (sub)file data dictionary #
 . for  do  quit:'file  ; traverse dd #s
 . . set file=$order(ddpfda(file)) ; get next dd #
 . . quit:'file  ; until no more (sub)files
 . . ;
 . . new j set j=0 ; value #, count of values
 . . for  do  quit:'j  ; traverse values to validate
 . . . set j=$order(ddpfda(file,j)) ; get next value #
 . . . quit:'j  ; until no more values
 . . . ;
 . . . new iens set iens=ddpfda(file,j,"ien") ; record number
 . . . new field set field=+ddpfda(file,j,"dd") ; field number
 . . . new value set value=ddpfda(file,j,"value") ; value to check
 . . . ;
 . . . ; ddffda(2,"+1,",.01)="abc"
 . . . set ddffda(+file,iens,field)=value ; fda node for this value
 . . . quit
 . . quit
 . quit
 ;
 ; new parsed ; Parsed array which stores each line on a separate node.
 ; do PARSE10^VPRJRUT(.body,.parsed) ; parser
 ; new ddwfda merge ddwfda=parsed
 ;
 ; step 3: validate the values
 ;
 new ddfout ; array to receive validated internal values
 new ddferr ; array to receive error messages from fileman
 ;
 do VALS^DIE("",$name(ddffda),$name(ddfout),$name(ddferr))
 ;
 ; step 4: if errors, make them the output
 ;
 ; In case of error, construct error array
 ; Make sure the numbers are javascript friendly!!!
 ;
 if $data(DIERR) do
 . kill ddfout
 . new i set i=0
 . for  do  quit:'i
 . . set I=$order(ddferr("DIERR",i))
 . . quit:'i
 . . new file set file=ddferr("DIERR",i,"PARAM","FILE")
 . . new field set field=ddferr("DIERR",i,"PARAM","FIELD")
 . . new errno set errno=ddferr("DIERR",i)
 . . new text set text=""
 . . new j set j=0
 . . for  do  quit:'j
 . . . set j=$order(ddferr("DIERR",i,"TEXT",j))
 . . . quit:'j
 . . . set text=text_ddferr("DIERR",i,"TEXT",j)_" "
 . . . quit
 . . set $extract(text,$length(text))=""
 . . set result("errors",i,$$JSN(file)_","_$$JSN(field))=errno_U_text
 . . quit
 . quit
 ;
 ; step 5: if valid, make internal values the output
 ;
 else  do  ; send back the filer data array
 . new v set v=$name(ddfout)
 . new count set count=1
 . for  do  quit:'$length(v)
 . . set v=$query(@v)
 . . quit:'$length(v)
 . . set result("fda",count,v)=@v
 . . set count=count+1
 . . quit
 . quit
 ;
 ; step 6: encode output array as json object
 ;
 do
 . ; zshow "v":^KBANFDA
 . ; to do: dderr - deal with this.
 . ;
 . new ddjson ; array to receive json object
 . new dderr ; array to receive error messages
 . ;
 . do ENCODE^VPRJSON($name(result),$name(ddjson),$name(dderr))
 . ;
 . kill result merge result=ddjson ; make json object the output
 . ;
 . ; merge ^TMP($job)=^KBANFDA("V")
 . ; set result=$name(^TMP($job))
 . ; if $data(^TMP($job)) do ADDCRLF^VPRJRUT(.result) ; crlf the result
 . ;
 . quit
 ;
 quit "" ; end of $$VALS
 ;
 ;
JSN(number) ; convert number from mumps format to javascript
 ;ven/smh&toad;private;function;clean;silent;sac
 ; called by:
 ;   VALS
 ; calls: none
 ; input:
 ;   number = number in mumps format
 ; output = number converted to javascript format
 ; examples:
 ;   [develop examples]
 ;
 ; mumps decimal numbers have no leading zero.
 ; javascript decimal numbers do.
 ; this function converts mumps numbers to javascript format.
 ;
 if $extract(number)="." do
 . set number=0_number ; prepend zero
 . quit
 ;
 quit number ; end of $$JSN
 ;
 ;
 ;
 ; web service post fileman/fda subroutines
 ;
 ;
 ;
FDAPOST(ARGS,BODY,RESULT) ; web service post fileman/fda - update
 ;ven/smh&toad;private;procedure;clean;silent;sac
 ; called by:
 ;   m-web-server
 ; calls:
 ;   PARSE10^VPRJRUT: parse array by crlf
 ;   $$UP^VPRJRUT = convert string to uppercase
 ;   UPDATE^DIE: update field(s) in one or more (sub)file(s)
 ;   SETERROR^VPRJRUT: set error info into ^TMP("HTTPERR",$job)
 ;   CLEAN^DILF: clear fileman's silent-mode flags & arrays
 ; input:
 ;   ARGS
 ;   BODY
 ; output:
 ;   RESULT
 ; examples:
 ;   [develop examples]
 ;
 new PARSED ; Parsed array which stores each line on a separate node.
 do PARSE10^VPRJRUT(.BODY,.PARSED) ; Parse by CR/LF
 ;
 ; Process flags
 new FLAGS set FLAGS=""
 if $data(ARGS("flags")) do
 . set FLAGS=$$UP^VPRJRUT(ARGS("flags"))
 . quit
 ;
 ; Set FDA
 new I set I="" 
 for  do  quit:I=""
 . set I=$order(PARSED(I))
 . quit:I=""
 . if PARSED(I)'="" do
 . . set @PARSED(I)
 . . quit
 . quit
 ;
 new DIERR
 new IEN,FILE
 set FILE=$order(FDA(""))
 do UPDATE^DIE(FLAGS,$name(FDA),$name(IEN))
 ;
 if $data(DIERR) do  quit ""
 . new ERROR
 . new I set I=0
 . for  do  quit:'I
 . . set I=$order(^TMP("DIERR",$job,I))
 . . quit:'I
 . . merge ERROR("PARAM")=^TMP("DIERR",$job,I,"PARAM")
 . . set ERROR("PARAM","CODE")=^TMP("DIERR",$job,I)
 . . merge ERROR("TEXT")=^TMP("DIERR",$job,I,"TEXT")
 . . do SETERROR^VPRJRUT(400,,.ERROR)
 . . quit
 . do CLEAN^DILF ; Remove Fileman temp vars
 . quit
 ;
 quit "/fileman/"_FILE_"/"_IEN(1) ; end of $$FDAPOST
 ;
 ;
 ; was what follows an example to help write the error code above?
 ;
 ; ^KBANFDA("V",4)="DDFERR(""DIERR"")=""1^1"""
 ; ^KBANFDA("V",5)="DDFERR(""DIERR"",1)=701"
 ; ^KBANFDA("V",6)="DDFERR(""DIERR"",1,""PARAM"",0)=4"
 ; ^KBANFDA("V",7)="DDFERR(""DIERR"",1,""PARAM"",3)=""asdf"""
 ; ^KBANFDA("V",8)="DDFERR(""DIERR"",1,""PARAM"",""FIELD"")=.01"
 ; ^KBANFDA("V",9)="DDFERR(""DIERR"",1,""PARAM"",""FILE"")=2"
 ; ^KBANFDA("V",10)="DDFERR(""DIERR"",1,""PARAM"",""IENS"")=""+1,"""
 ; ^KBANFDA("V",11)="DDFERR(""DIERR"",1,""TEXT"",1)=""The value 'asdf' for field NAME in file PATIENT is not valid."""
 ; ^KBANFDA("V",12)="DDFERR(""DIERR"",""E"",701,1)="""""
 ;
 ;
 ;
 ; testing subroutines
 ;
 ;
 ;
TEST ; test DD^dw, uses asserts
 ;ven/smh&toad;private;procedure;clean;silent;sac
 ; called by:
 ; calls:
 ; input:
 ; output:
 ; examples:
 ;   [develop examples]
 ;
 new F set F("fields")=".85,.01:999"
 new KBANR
 do DD(.KBANR,.F)
 new KBANJ
 do DECODE^VPRJSON($name(KBANR),$name(KBANJ))
 ; zwrite KBANR
 ; zwrite KBANJ
 do ASSERT($data(KBANJ("0.85,0.01")))
 do ASSERT($data(KBANJ("0.85,0.06")))
 ;
 quit  ; end of TEST
 ;
 ;
TEST2 ; test $$VALS^dw, uses zwrites
 ;ven/smh&toad;private;procedure;clean;silent;sac
 ; called by:
 ; calls:
 ; input:
 ; output:
 ; examples:
 ;   [develop examples]
 ;
 set JSON(1)="{""0.85"":[{""dd"":""0.01"",""ien"":""+1,"",""value"":""""},{""dd"":""0.02"",""ien"":""+1,"",""value"":""""},{""dd"":""0.03"",""ien"":""+1,"",""value"":""""},{""dd"":""0.04"",""ien"":""+1,"",""value"":""""},{""dd"":""0.05"",""ien"":""+1,"",""value"":""""},{""dd"":""0.06"",""ien"":""+1,"",""value"":""""},{""dd"":""0.07"",""ien"":""+1,"",""value"":""""},{""dd"":""0.08"",""ien"":""+1,"",""value"":""""},{""dd"":""0.09"",""ien"":""+1,"",""value"":""777777""},{""dd"":""10.1"",""ien"":""+1,"",""value"":""""},{""dd"":""10.2"",""ien"":""+1,"",""value"":""""},{""dd"":""10.21"",""ien"":""+1,"",""value"":""""},{""dd"":""10.22"",""ien"":""+1,"",""value"":""""},{""dd"":""10.3"",""ien"":""+1,"",""value"":""""},{""dd"":""10.4"",""ien"":""+1,"",""value"":""""},{""dd"":""10.5"",""ien"":""+1,"",""value"":""""},{""dd"":""20.2"",""ien"":""+1,"",""value"":""THIS IS NOT STANDARD MUMPS CODE""}]}"
 set %=$$VALS(,.JSON,.RES)
 zwrite RES
 ;
 quit  ; end of TEST2
 ;
 ;
ASSERT(CONDITION) ; assertion procedure, throws mumps error
 ;ven/smh&toad;private;procedure;clean;silent;sac
 ; called by:
 ; calls:
 ; input:
 ;   CONDITION = 
 ; output:
 ; examples:
 ;   [develop examples]
 ;
 if 'CONDITION set $ecode=",U-ASSERTION-FAILED,"
 ;
 quit  ; end of ASSERT
 ;
 ;
eor ; end of routine dw
