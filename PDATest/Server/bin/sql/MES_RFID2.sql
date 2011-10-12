SELECT PW.RFID,PW.PROSN,JD.MATCODE,PA.PRAMATCODE 
FROM   DC_PROWORK     PW Inner Join JM_JOBDISPATCH JD ON PW.JODNO = JD.JODNO
                         Inner Join DC_PROASSEMBLY PA ON PA.PROSN = PW.PROSN   
WHERE  PW.RFID  =:1               AND 
       PW.PRWWORKING   = '11'     AND  
       PA.PROWORKCENTER= 'D'      AND     
       PA.PRWWORKING   = '20'