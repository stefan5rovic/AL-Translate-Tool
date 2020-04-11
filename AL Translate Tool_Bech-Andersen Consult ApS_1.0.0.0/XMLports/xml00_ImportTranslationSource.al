xmlport 78600 "BAC Import Translation Source"
{
    Caption = 'Import Translation Source';
    DefaultNamespace = 'urn:oasis:names:tc:xliff:document:1.2';
    Direction = Import;
    Encoding = UTF16;
    FileName = 'C:\Users\Peikba\Desktop\ManPlus.xml';
    XmlVersionNo = V10;
    Format = Xml;
    PreserveWhiteSpace = true;
    UseDefaultNamespace = true;
    UseRequestPage = false;
    UseLax = true;

    schema
    {
        textelement(xliff)
        {
            textattribute(version)
            {
                trigger OnAfterAssignVariable()
                begin
                    TransProject."Xliff Version" := version;
                end;
            }
            textelement(infile)
            {
                XmlName = 'file';
                textattribute(datatype)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        TransProject."File Datatype" := datatype;
                    end;

                }
                textattribute("source-language")
                {
                    trigger OnAfterAssignVariable()
                    var
                        WrongSourceLangTxt: Label '%1 must be %2 in file - The file %1 is %3';
                    begin
                        if TransProject."Source Language ISO code" <> "source-language" then
                            error(WrongSourceLangTxt, TransProject.FieldCaption("Source Language"), TransProject."Source Language ISO code", "source-language");
                    end;

                }

                textattribute("target-language")
                {
                    Occurrence = Optional;
                }
                textattribute(original)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        TransProject.OrginalAttr := original;
                    end;
                }
                textelement(body)
                {
                    textelement(group)
                    {

                        textattribute(id1)
                        {
                            XmlName = 'id';
                        }
                        tableelement(Source; "BAC Translation Source")
                        {
                            XmlName = 'trans-unit';

                            fieldattribute(id; Source."Trans-Unit Id")
                            {
                            }
                            fieldattribute("maxWidth"; Source."Max Width")
                            {
                                Occurrence = Optional;
                            }
                            textattribute("size-unit")
                            {
                                trigger OnAfterAssignVariable()
                                begin
                                    Source."size-unit" := "size-unit";
                                end;
                            }
                            textattribute(translate)
                            {
                                trigger OnAfterAssignVariable()
                                begin
                                    source.TranslateAttr := translate;
                                end;
                            }
                            textattribute("al-object-target")
                            {
                                Occurrence = Optional;
                                trigger OnAfterAssignVariable()
                                begin
                                    Source."al-object-target" := "al-object-target";
                                end;
                            }
                            fieldelement(source; Source.Source)
                            {
                            }

                            textelement(note)
                            {
                                textattribute(from)
                                {
                                    trigger OnAfterAssignVariable()
                                    begin
                                        TransNotes.From := from;
                                    end;
                                }
                                textattribute(annotates)
                                {
                                    trigger OnAfterAssignVariable()
                                    begin
                                        TransNotes.Annotates := annotates;
                                    end;
                                }
                                textattribute(priority)
                                {
                                    trigger OnAfterAssignVariable()
                                    begin
                                        TransNotes.Priority := priority;
                                    end;
                                }
                                trigger OnAfterAssignVariable()
                                begin
                                    TransNotes.Note := note;
                                    CreateTranNote();
                                end;
                            }
                            trigger OnBeforeInsertRecord()
                            begin
                                LineCounter += 1;
                                Window.Update(1, LineCounter);
                                if ProjectCode = '' then
                                    error(MissingProjNameTxt);
                                Source."Project Code" := ProjectCode;
                            end;

                        }
                    }
                }
            }
        }
    }

    var
        TransNotes: Record "BAC Translation Notes";
        TransProject: Record "BAC Translation Project Name";
        Window: Dialog;
        ProjectCode: Code[10];
        MissingProjNameTxt: Label 'Project Name is Missing';
        LineCounter: Integer;

    trigger OnPreXmlPort()
    begin
        Window.Open('Processing line No. #1####');
    end;

    trigger OnPostXmlPort()
    begin
        Window.Close();
        with TransProject do begin
            "File Name" := CopyStr(currXMLport.Filename(), 1, MaxStrLen("File Name"));
            while (StrPos("File Name", '\') > 0) do
                "File Name" := CopyStr("File Name", StrPos("File Name", '\') + 1, MaxStrLen("File Name"));
            Modify();
        end;
    end;

    procedure SetProjectCode(inProjectCode: Code[10])
    begin
        ProjectCode := inProjectCode;
        TransProject.Get(ProjectCode);
    end;

    local procedure CreateTranNote()
    begin
        if (TransNotes.From <> '') and
           (TransNotes.Annotates <> '') and
           (TransNotes.Priority <> '') then begin
            TransNotes."Project Code" := ProjectCode;
            TransNotes."Trans-Unit Id" := Source."Trans-Unit Id";
            if TransNotes.Insert() then;
            clear(TransNotes);
        end;
    end;
}

