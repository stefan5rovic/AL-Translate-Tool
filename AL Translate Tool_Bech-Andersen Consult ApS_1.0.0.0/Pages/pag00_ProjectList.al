page 78600 "BAC Trans Project List"
{
    Caption = 'Translation Project List';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "BAC Translation Project Name";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Project Code"; "Project Code")
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    trigger OnAssistEdit();
                    begin
                        if AssistEdit() then
                            CurrPage.Update();
                    end;

                }
                field("Project Name"; "Project Name")
                {
                    ApplicationArea = All;

                }
                field("Source Language"; "Source Language")
                {
                    ApplicationArea = All;
                }
                field("Source Language ISO code"; "Source Language ISO code")
                {
                    ApplicationArea = All;
                }
                field("Created By"; "Created By")
                {
                    ApplicationArea = All;

                }
                field("Creation Date"; "Creation Date")
                {
                    ApplicationArea = All;

                }
                field("NAV Version"; "NAV Version")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action("Import Source")
            {
                ApplicationArea = All;
                Caption = 'Import Source';
                Image = ImportCodes;
                Promoted = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    TransSource: Record "BAC Translation Source";
                    TransNotes: Record "BAC Translation Notes";
                    TransProject: Record "BAC Translation Project Name";
                    ImportSourceXML: XmlPort "BAC Import Translation Source";
                    ImportSource2018XML: XmlPort "BAC Import Trans. Source 2018";
                    DeleteWarningTxt: Label 'This will overwrite the Translation source for %1';
                    ImportedTxt: Label 'The file %1 has been imported into project %2';
                begin
                    TransSource.SetRange("Project Code", "Project Code");
                    if not TransSource.IsEmpty() then
                        if Confirm(DeleteWarningTxt, false, "Project Code") then begin
                            TransSource.DeleteAll();
                            TransNotes.DeleteAll();
                        end else
                            exit;
                    case "NAV Version" of
                        "NAV Version"::"Dynamics 365 Business Central":
                            begin
                                ImportSourceXML.SetProjectCode(Rec."Project Code");
                                ImportSourceXML.Run();
                            end;
                        "NAV Version"::"Dynamics NAV 2018":
                            begin
                                ImportSource2018XML.SetProjectCode(Rec."Project Code");
                                ImportSource2018XML.Run();
                            end;
                    end;
                    TransProject.Get("Project Code");
                    message(ImportedTxt, TransProject."File Name", "Project Code");
                end;
            }

            action(ImportSrcFromText)
            {
                ApplicationArea = All;
                Caption = 'Import Source From Text';
                Image = ImportCodes;
                Promoted = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    ImportSourceFromText();
                end;
            }
        }
        area(Navigation)
        {
            action("Translation Source")
            {
                ApplicationArea = All;
                Caption = 'Translation Source';
                Image = SourceDocLine;
                Promoted = true;
                PromotedOnly = true;
                RunObject = page "BAC Translation Source List";
                RunPageLink = "Project Code" = field("Project Code");
            }
            action("Target Languages")
            {
                ApplicationArea = All;
                Caption = 'Target Languages';
                Image = Language;
                Promoted = true;
                PromotedOnly = true;
                RunObject = page "BAC Target Language List";
                RunPageLink = "Project Code" = field("Project Code"),
                              "Source Language" = field("Source Language"),
                              "Source Language ISO code" = field("Source Language ISO code");
            }
        }
    }
    procedure ImportSourceFromText()
    var
        TransSource: Record "BAC Translation Source";
        TransNotes: Record "BAC Translation Notes";
        //TransProject: Record "BAC Translation Project Name";
        Language: Record Language;
        InStream: InStream;
        LineNo: Integer;
        DeleteWarningTxt: Label 'This will overwrite the Translation source for %1';
        FileName: Text;
        TextLine: Text;
        RightPart: Text;
        LeftPart: Text;
    begin
        TransSource.SetRange("Project Code", GetFilter("Project Code"));
        if not TransSource.IsEmpty() then
            if Confirm(DeleteWarningTxt, false, "Project Code") then begin
                TransSource.DeleteAll();
                TransNotes.DeleteAll();
            end else
                exit;

        if UploadIntoStream('', '', 'All Files (*.*)|*.*', FileName, InStream) then
            while InStream.ReadText(TextLine) > 0 do begin
                LineNo += 1;
                LeftPart := COPYSTR(TextLine, 1, STRPOS(TextLine, ':') - 1);
                RightPart := COPYSTR(TextLine, STRPOS(TextLine, ':') + 1);
                Language.Get("Source Language");
                if LeftPart.Contains(format(Language."Windows Language ID")) then begin
                    TransSource."Line No." := LineNo;
                    TransSource."Project Code" := "Project Code";
                    TransSource."Trans-Unit Id" := CopyStr(LeftPart, 1, MaxStrLen(TransSource."Trans-Unit Id"));
                    TransSource.Source := CopyStr(RightPart, 1, MaxStrLen(TransSource.Source));
                    TransSource.Insert();
                end;
            end;
    end;
}