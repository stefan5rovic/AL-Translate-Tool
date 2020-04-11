page 78603 "BAC Translation Target List"
{
    Caption = 'Translation Target List';
    PageType = List;
    SourceTable = "BAC Translation Target";
    PopulateAllFields = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                }
                field("Trans-Unit Id"; "Trans-Unit Id")
                {
                    ApplicationArea = All;
                }
                field(Source; Source)
                {
                    ApplicationArea = All;
                }
                field(Translate2; Translate)
                {
                    ApplicationArea = All;
                    ToolTip = 'Set the Translate field to no if you don''t want it to be translated';
                }
                field(Target; Target)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the translated text';
                }
                /*field(Occurrencies; Occurrencies)
                {
                    Visible = false;
                    ApplicationArea = All;
                }*/
            }
        }
        area(Factboxes)
        {
            part(TransNotes; "BAC Translation Notes")
            {
                ApplicationArea = All;
                SubPageLink = "Project Code" = field("Project Code"),
                            "Trans-Unit Id" = field("Trans-Unit Id");
                Editable = false;
            }
            part(TargetFactbox; "BAC Trans Target Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "Project Code" = field("Project Code"),
                            "Trans-Unit Id" = field("Trans-Unit Id");
            }

        }

    }

    actions
    {
        area(Processing)
        {
            action(CopyFromSource)
            {
                ApplicationArea = All;
                Image = Copy;
                Caption = 'Copy from Source';
                Promoted = true;

                trigger OnAction()
                begin
                    TransferSourceToTarget();
                end;
            }
            action("GoPro Send Line To Gen. Translation Terms")
            {
                ApplicationArea = All;
                Caption = 'GoPro Send Line To Gen. Translation Terms';
                Image = Translation;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    BACTranslationTarget: Record "BAC Translation Target";
                    BACGenTranslationTerm: Record "BAC Gen. Translation Term";
                    BACGenTranslationCheck: Record "BAC Gen. Translation Term";
                    BACGenTranslationLast: Record "BAC Gen. Translation Term";
                    LastLineNoL: Integer;
                begin
                    BACTranslationTarget.Reset();
                    CurrPage.SetSelectionFilter(BACTranslationTarget);
                    IF BACTranslationTarget.FindSet() then
                        repeat
                            IF BACTranslationTarget.Target = '' then
                                Error('Nemate vrednost u polju %1, red ne može biti primenjen', FieldCaption(Target));

                            BACGenTranslationCheck.Reset();
                            BACGenTranslationCheck.SetRange("Target Language", BACTranslationTarget."Target Language");
                            BACGenTranslationCheck.SetRange(Term, BACTranslationTarget.Source);
                            IF BACGenTranslationCheck.FindFirst() then begin
                                BACGenTranslationCheck.Translation := BACTranslationTarget.Target;
                                BACGenTranslationCheck.Modify();
                                Message('Već postoji red sa poljem %1 = %2, nije kreiran novi red već je ažuriran postojeći', BACGenTranslationCheck.FieldCaption(Term), Source);
                            end ELSE begin
                                BACGenTranslationLast.Reset();
                                IF BACGenTranslationLast.FindLast() then
                                    LastLineNoL := BACGenTranslationLast."Line No."
                                else
                                    LastLineNoL := 0;

                                BACGenTranslationTerm.Init();
                                BACGenTranslationTerm."Line No." := LastLineNoL + 10000;
                                BACGenTranslationTerm."Target Language" := BACTranslationTarget."Target Language";
                                BACGenTranslationTerm.Term := BACTranslationTarget.Source;
                                BACGenTranslationTerm.Translation := BACTranslationTarget.Target;
                                BACGenTranslationTerm.Insert();
                            end;
                        until BACTranslationTarget.Next() = 0;

                end;
            }
            action("GoPro Translate")
            {
                ApplicationArea = All;
                Caption = 'GoPro Translate';
                Image = Translation;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    Project: Record "BAC Translation Project Name";
                    TransTerm: Record "BAC Translation Term";
                    BACTranslationTarget: Record "BAC Translation Target";
                begin
                    Project.get("Project Code");
                    //Target := ReplaceTermInTranslation(Target);
                    BACTranslationTarget.Reset();
                    BACTranslationTarget.SetRange(Translate, true);
                    BACTranslationTarget.SetRange("Project Code", Rec."Project Code");
                    BACTranslationTarget.SetRange("Target Language", Rec."Target Language");
                    //MESSAGE(Format(BACTranslationTarget.Count));//temp 2 
                    IF BACTranslationTarget.FindSet(true) then
                        repeat
                            TransTerm.Reset();
                            TransTerm.SetRange("Project Code", BACTranslationTarget."Project Code");
                            TransTerm.SetRange("Target Language", BACTranslationTarget."Target Language");
                            TransTerm.SetRange(Term, BACTranslationTarget.Source);
                            IF TransTerm.FindFIRST() THEN begin
                                BACTranslationTarget.Target := TransTerm.Translation;
                                BACTranslationTarget.Modify();
                            end;
                        until BACTranslationTarget.Next() = 0;
                end;
            }
            action("Translate")
            {
                ApplicationArea = All;
                Caption = 'Translate';
                Image = Translation;
                Promoted = true;
                PromotedOnly = true;
                Enabled = ShowTranslate;

                trigger OnAction();
                var
                    Project: Record "BAC Translation Project Name";
                    GoogleTranslate: Codeunit "BAC Google Translate Rest";
                begin
                    Project.get("Project Code");
                    Target := GoogleTranslate.Translate(Project."Source Language ISO code",
                                              "Target Language ISO code",
                                              Source);
                    Target := ReplaceTermInTranslation(Target);
                    Validate(Target);
                end;
            }
            action("Translate All")
            {
                ApplicationArea = All;
                Caption = 'Translate All';
                Image = Translations;
                Promoted = true;
                PromotedOnly = true;
                Enabled = ShowTranslate;

                trigger OnAction();
                var
                    MenuSelectionTxt: Label 'Convert all,Convert only missing';
                begin
                    case StrMenu(MenuSelectionTxt, 1) of
                        1:
                            TranslateAll(false);

                        2:
                            TranslateAll(true);
                    end;
                end;
            }
            action("Select All")
            {
                ApplicationArea = All;
                Caption = 'Select All';
                Image = Approve;
                Promoted = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    TransTarget: Record "BAC Translation Target";
                    WarningTxt: Label 'Mark all untranslated lines to be translated?';
                begin
                    CurrPage.SetSelectionFilter(TransTarget);
                    if TransTarget.Count() = 1 then
                        TransTarget.Reset();
                    TransTarget.SetRange(Target, '');
                    if Confirm(WarningTxt) then
                        TransTarget.ModifyAll(Translate, true);
                    CurrPage.Update(false);

                end;
            }
            action("Deselect All")
            {
                ApplicationArea = All;
                Caption = 'Deselect All';
                Image = Cancel;
                Promoted = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    TransTarget: Record "BAC Translation Target";
                    WarningTxt: Label 'Remove mark from all lines and disable translation?';
                begin
                    CurrPage.SetSelectionFilter(TransTarget);
                    if TransTarget.Count() = 1 then
                        TransTarget.Reset();
                    if Confirm(WarningTxt) then
                        TransTarget.ModifyAll(Translate, false);
                    CurrPage.Update(false);
                end;
            }
            action("Clear All translations")
            {
                ApplicationArea = All;
                Caption = 'Clear All translations within filter';
                Image = RemoveLine;
                Promoted = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    TransTarget: Record "BAC Translation Target";
                    WarningTxt: Label 'Remove all translations?';
                begin
                    CurrPage.SetSelectionFilter(TransTarget);
                    if TransTarget.Count() = 1 then
                        TransTarget.Reset();
                    if Confirm(WarningTxt) then
                        TransTarget.ModifyAll(Target, '');
                end;
            }
            action("Translation Terms")
            {
                Caption = 'Translation Terms';
                ApplicationArea = All;
                Image = BeginningText;
                Promoted = true;
                PromotedOnly = true;
                RunObject = page "BAC Translation terms";
                RunPageLink = "Project Code" = field("Project Code"),
                            "Target Language" = field("Target Language");
            }
            action("Export Translation File")
            {
                ApplicationArea = All;
                Caption = 'Export Translation File';
                Image = ExportFile;
                Promoted = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    TransProject: Record "BAC Translation Project Name";
                    ExportTranslation: XmlPort "BAC Export Translation Target";
                    ExportTranslation2018: XmlPort "BAC Export Trans Target 2018";
                    WarningTxt: Label 'Export the Translation file?';
                begin
                    if Confirm(WarningTxt) then begin
                        TransProject.get("Project Code");
                        case TransProject."NAV Version" of
                            TransProject."NAV Version"::"Dynamics 365 Business Central":
                                begin
                                    ExportTranslation.SetProjectCode("Project Code", TransProject."Source Language ISO code", "Target Language ISO code");
                                    ExportTranslation.Run();
                                end;
                            TransProject."NAV Version"::"Dynamics NAV 2018":
                                begin
                                    ExportTranslation2018.SetProjectCode("Project Code", TransProject."Source Language ISO code", "Target Language ISO code");
                                    ExportTranslation2018.Run();
                                end;
                        end;
                    end;
                end;

            }

            action("Export Translation to Text")
            {
                ApplicationArea = All;
                Caption = 'Export Translation File to Text';
                Image = ExportFile;
                Promoted = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    ExportTargetToText();
                end;
            }
        }
    }
    var
        [InDataSet]
        ShowTranslate: Boolean;


    trigger OnOpenPage()
    var
        //TransSource: Record "BAC Translation Source";
        //TransTarget: Record "BAC Translation Target";
        TransSetup: Record "BAC Translation Setup";
    begin
        TransSetup.get();
        ShowTranslate := TransSetup."Use Free Google Translate";

        //TransSource.SetFilter("Project Code", GetFilter("Project Code"));
        if IsEmpty() then
            TransferSourceToTarget();
        /*if TransSource.FindSet() then
            repeat
                TransTarget.TransferFields(TransSource);
                TransTarget."Target Language" := CopyStr(GetFilter("Target Language"), 1, MaxStrLen(TransTarget."Target Language"));
                TransTarget."Target Language ISO code" := CopyStr(GetFilter("Target Language ISO code"), 1, MaxStrLen(TransTarget."Target Language ISO code"));
                if TransTarget.Insert() then;
            until TransSource.Next() = 0;*/
    end;

    local procedure TransferSourceToTarget()
    var
        TransSource: Record "BAC Translation Source";
        TransTarget: Record "BAC Translation Target";
    begin
        TransSource.SetFilter("Project Code", GetFilter("Project Code"));
        if TransSource.FindSet() then
            repeat
                TransTarget.TransferFields(TransSource);
                TransTarget."Target Language" := CopyStr(GetFilter("Target Language"), 1, MaxStrLen(TransTarget."Target Language"));
                TransTarget."Target Language ISO code" := CopyStr(GetFilter("Target Language ISO code"), 1, MaxStrLen(TransTarget."Target Language ISO code"));
                TransTarget."al-object-target" := TransSource."al-object-target";
                if TransTarget.Insert() then;
            until TransSource.Next() = 0;
    end;

    local procedure TranslateAll(inOnlyEmpty: Boolean)
    var
        TransTarget: Record "BAC Translation Target";
        TransTarget2: Record "BAC Translation Target";
        Project: Record "BAC Translation Project Name";
        GoogleTranslate: Codeunit "BAC Google Translate Rest";
        Window: Dialog;
        DialogTxt: Label 'Converting #1###### of #2######';
        Counter: Integer;
        TotalCount: Integer;
    begin
        if inOnlyEmpty then
            TransTarget.SetRange(Target, '');
        TransTarget.SetRange(Translate, true);
        TransTarget.SetRange("Project Code", "Project Code");
        Project.get("Project Code");
        TotalCount := TransTarget.Count();
        TransTarget.SetRange(Occurrencies, 1);
        if TransTarget.FindSet() then begin
            Window.Open(DialogTxt);
            repeat
                Counter += 1;
                Window.Update(1, Counter);
                Window.Update(2, TotalCount);
                TransTarget.Target := GoogleTranslate.Translate(Project."Source Language ISO code",
                                          "Target Language ISO code",
                                          TransTarget.Source);
                TransTarget.Target := ReplaceTermInTranslation(TransTarget.Target);
                TransTarget.Translate := false;
                TransTarget.Modify();
                commit();
            until TransTarget.Next() = 0;
        end;
        // To avoid the Sorry message (Another user has change the record)
        TransTarget.Reset();
        if inOnlyEmpty then
            TransTarget.SetRange(Target, '');
        TransTarget.SetRange(Translate, true);
        TransTarget.SetRange("Project Code", "Project Code");
        TransTarget.SetCurrentKey(Source);
        TransTarget.SetFilter(Occurrencies, '>1');
        if TransTarget.FindSet() then
            repeat
                Counter += 1;
                Window.Update(1, Counter);
                Window.Update(2, TotalCount);
                TransTarget.Target := GoogleTranslate.Translate(Project."Source Language ISO code",
                                          "Target Language ISO code",
                                          TransTarget.Source);
                TransTarget.Target := ReplaceTermInTranslation(TransTarget.Target);
                TransTarget2.SetFilter(Source, TransTarget.Source);
                TransTarget2.ModifyAll(Target, TransTarget.Target);
                TransTarget.ModifyAll(Translate, false);
                commit();
                SelectLatestVersion();
                TransTarget.SetFilter(Source, '<>%1', TransTarget.Source);
            until TransTarget.Next() = 0;

    end;

    local procedure ReplaceTermInTranslation(inTarget: Text) outTarget: Text[2048]
    var
        TransTerm: Record "BAC Translation Term";
        StartPos: Integer;
        StartLetterIsUppercase: Boolean;
        Found: Boolean;
    begin
        if TransTerm.FindSet() then
            repeat
                StartPos := strpos(LowerCase(inTarget), LowerCase(TransTerm.Term));
                if StartPos > 0 then begin
                    StartLetterIsUppercase := copystr(inTarget, StartPos, 1) = uppercase(copystr(inTarget, StartPos, 1));
                    if StartLetterIsUppercase then
                        TransTerm.Translation := UpperCase(TransTerm.Translation[1]) + CopyStr(TransTerm.Translation, 2)
                    else
                        TransTerm.Translation := LowerCase(TransTerm.Translation[1]) + CopyStr(TransTerm.Translation, 2);
                    if (StartPos > 1) then begin
                        outTarget := CopyStr(inTarget, 1, StartPos - 1) +
                                     TransTerm.Translation +
                                     CopyStr(inTarget, StartPos + strlen(TransTerm.Term));
                        Found := true;
                    end else begin
                        outTarget := TransTerm.Translation +
                                     CopyStr(inTarget, strlen(TransTerm.Term) + 1);
                        Found := true;
                    end;
                end;
                if Found then
                    inTarget := outTarget;
            until TransTerm.Next() = 0;
        if not Found then
            outTarget := CopyStr(inTarget, 1, MaxStrLen(outTarget));
    end;

    local procedure ExportTargetToText()
    var
        TransTarger: Record "BAC Translation Target";
        TransLanguage: Record "BAC Target Language";
        Language: Record Language;
        TmpBlob: Record TempBlob temporary;
        InStream: InStream;
        OutStream: OutStream;
        ProgressWindow: Dialog;
        FileName: Text;
        SourceLanguageID: Text;
        TargetLanguageID: Text;
        OutputString: Text;
    begin
        TransTarger.CopyFilters(Rec);
        TmpBlob.Blob.CreateOutStream(OutStream, TextEncoding::UTF8);
        Language.Get(GetFilter("Target Language"));
        TargetLanguageID := 'A' + Format(Language."Windows Language ID");
        TransLanguage.Get(GetFilter("Project Code"), GetFilter("Target Language"));
        Language.Get(TransLanguage."Source Language");
        SourceLanguageID := 'A' + Format(Language."Windows Language ID");
        FileName := 'Translation_' + GetFilter("Project Code") + '_' + GetFilter("Target Language") + '.txt';
        ProgressWindow.Open('Exporting line no. #1######');
        If TransTarger.FindSet() then
            repeat
                ProgressWindow.Update(1, TransTarger."Line No.");
                OutputString := '';
                OutputString += TransTarger."Trans-Unit Id";
                OutputString := OutputString.Replace(SourceLanguageID, TargetLanguageID);
                if OutputString.EndsWith('L128') then begin
                    OutputString := CopyStr(OutputString, 1, StrLen(OutputString) - 4);
                    OutputString += TargetLanguageID + '-L999';
                end;
                OutputString += ':' + TransTarger.Target;
                OutStream.WriteText(OutputString);
                OutStream.WriteText();
            until TransTarger.Next() = 0;
        ProgressWindow.Close();
        TmpBlob.Blob.CreateInStream(InStream, TextEncoding::UTF8);
        DownloadFromStream(InStream, '', '', 'All Files (*.*)|*.*', FileName);
    end;
}