        ��  ��                  {  0   ��
 R O D L F I L E                     <?xml version="1.0" encoding="utf-8"?>
<Library Name="BankSvrLib" UID="{A4E0D59C-DBA0-4ABD-B359-FEB861DF1348}" Version="3.0">
<Services>
<Service Name="BankService" UID="{4515EC88-54E8-4241-96DE-14C44CABD7BD}">
<Interfaces>
<Interface Name="Default" UID="{1AA774B9-B606-4BF3-A278-A2BCFB5B2D86}">
<Documentation><![CDATA[Service BankService. This service has been automatically generated using the RODL template you can find in the Templates directory.]]></Documentation>
<Operations>
<Operation Name="GetSvrDt" UID="{2EE28611-EB3B-4AFC-B83B-DDC51F6804BA}">
<Parameters>
<Parameter Name="Result" DataType="DateTime" Flag="Result">
</Parameter>
</Parameters>
</Operation>
<Operation Name="QueryAccValue_S" UID="{A6FBD737-8212-49F2-A7CB-E7FC2D2475B9}">
<Parameters>
<Parameter Name="Result" DataType="Boolean" Flag="Result">
</Parameter>
<Parameter Name="fSeqno" DataType="AnsiString" Flag="In" >
</Parameter>
<Parameter Name="AccNo0" DataType="AnsiString" Flag="In" >
</Parameter>
<Parameter Name="rtCode" DataType="AnsiString" Flag="InOut" >
</Parameter>
<Parameter Name="rtMsg" DataType="AnsiString" Flag="InOut" >
</Parameter>
<Parameter Name="rtStr" DataType="AnsiString" Flag="InOut" >
</Parameter>
</Parameters>
</Operation>
</Operations>
</Interface>
</Interfaces>
</Service>
</Services>
<Structs>
</Structs>
<Enums>
</Enums>
<Arrays>
</Arrays>
</Library>
