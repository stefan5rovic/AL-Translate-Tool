report 78600 "ImportGeneralTranslationTerms"
{
    //>>GPI-46986-T9H2AA-13.12.2019.-BRA-
    //   - New object

    CaptionML = ENU = 'Import General Translation Terms',
                SRM = 'Import General Translation Terms';
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = Administration;

    dataset
    {
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    CaptionML = ENU = 'Options',
                                SRM = 'Opcije';
                    group("Import From")
                    {
                        CaptionML = ENU = 'Import From',
                                    SRM = 'Uvezi iz';
                        field(FileNameG; FileName)
                        {
                            CaptionML = ENU = 'Workbook File Name',
                                        SRM = 'Ime datoteke';
                            Editable = false;
                            ApplicationArea = All;

                            trigger OnAssistEdit();
                            begin
                                RequestFile();

                                SheetName := ExcelBufferG.SelectSheetsName(ServerFileNameG);
                            end;

                            trigger OnValidate();
                            begin
                                FileNameOnAfterValidate();
                            end;
                        }
                        field(SheetNameG; SheetName)
                        {
                            CaptionML = ENU = 'Worksheet Name',
                                        SRM = 'Ime radnog lista';
                            Editable = false;
                            ApplicationArea = All;

                            trigger OnAssistEdit();
                            begin
                                IF ServerFileNameG = '' THEN
                                    RequestFile();

                                SheetName := ExcelBufferG.SelectSheetsName(ServerFileNameG);
                            end;
                        }
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage();
        begin
            FileName := '';
            SheetName := '';
        end;
    }

    labels
    {
    }

    trigger OnInitReport();
    var

    begin
    end;

    trigger OnPostReport();
    begin
        MESSAGE(ImportSuccessfulTxt);
        ExcelBufferG.DELETEALL();
    end;

    trigger OnPreReport();
    begin
        ExcelBufferG.DELETEALL();

        ExcelBufferG.OpenBook(ServerFileNameG, SheetName);
        ExcelBufferG.ReadSheet();

        ImportDataFromExcel();
    end;

    var
        ExcelBufferG: Record "Excel Buffer" temporary;
        FileManagementG: Codeunit "File Management";
        WindowDialogG: Dialog;
        FileName: Text;
        SheetName: Text[250];
        ServerFileNameG: Text;
        ImportExcelFileTxt: TextConst ENU = 'Import Excel File', SRM = 'Uvoz Excel datoteke';
        MustEnterFileNameErr: TextConst ENU = 'You must enter a file name.', SRM = 'Morate uneti ime fajla.';
        ProcessingDataTxt: TextConst ENU = 'Importing entris from Excel...\', SRM = 'Uvoz stavki iz Excela...\';
        StatusTxt: TextConst ENU = 'Status:             @1@@@@@@@@@@@@', SRM = 'Status:             @1@@@@@@@@@@@@';
        ImportSuccessfulTxt: TextConst ENU = 'Import successfull', SRM = 'Uvoz stavki uspešan';

    local procedure RequestFile();
    begin
        IF FileName <> '' THEN
            ServerFileNameG := FileManagementG.UploadFile(CopyStr(ImportExcelFileTxt, 1, 50), FileName)
        ELSE
            ServerFileNameG := FileManagementG.UploadFile(CopyStr(ImportExcelFileTxt, 1, 50), '.xlsx');

        ValidateServerFileName();

        FileName := FileManagementG.GetFileName(ServerFileNameG);
    end;

    local procedure FileNameOnAfterValidate();
    begin
        RequestFile();
    end;

    local procedure ValidateServerFileName();
    begin
        IF ServerFileNameG = '' THEN BEGIN
            FileName := '';
            SheetName := '';
            ERROR(MustEnterFileNameErr);
        END;
    end;

    procedure ImportDataFromExcel();
    var
        GenTransTermLastL: Record "BAC Gen. Translation Term";
        GenTransTermCheckL: Record "BAC Gen. Translation Term";
        GenTransTermL: Record "BAC Gen. Translation Term";
        ProcessPercentL: Decimal;
        NumberOfRowsL: Integer;
        NextUpdateTimeL: Time;
        LineNoL: Integer;
        RowNoL: Integer;
        TermL: Text[250];
        TranslationL: Text[250];
    begin
        WindowDialogG.OPEN(ProcessingDataTxt + StatusTxt);
        NextUpdateTimeL := TIME() + 1000;

        IF ExcelBufferG.FINDLAST() THEN
            NumberOfRowsL := ExcelBufferG."Row No.";

        GenTransTermLastL.RESET();
        GenTransTermLastL.SetRange("Target Language", TargetLanguageG);
        IF GenTransTermLastL.FINDLAST() THEN
            LineNoL := GenTransTermLastL."Line No."
        ELSE
            LineNoL := 0;

        ExcelBufferG.RESET();

        IF ExcelBufferG.FINDSET() THEN
            REPEAT
                IF ExcelBufferG."Column No." = 1 THEN
                    TermL := ExcelBufferG."Cell Value as Text"
                else begin
                    TranslationL := ExcelBufferG."Cell Value as Text";

                    GenTransTermCheckL.Reset();
                    GenTransTermCheckL.SetRange(Term, TermL);
                    IF GenTransTermCheckL.FindFirst() THEN begin
                        IF GenTransTermCheckL.Translation <> TranslationL THEN BEGIN
                            GenTransTermCheckL.Translation := TranslationL;
                            GenTransTermCheckL.Modify();
                        END;
                    end else begin
                        GenTransTermL.Init();
                        GenTransTermL."Target Language" := TargetLanguageG;
                        LineNoL += 10;
                        GenTransTermL."Line No." := LineNoL;
                        GenTransTermL.Term := TermL;
                        GenTransTermL.Translation := TranslationL;
                        GenTransTermL.Insert(true);
                        TermL := '';
                        TranslationL := '';
                    end;
                end;

                RowNoL += 1;
                ProcessPercentL := RowNoL / NumberOfRowsL;
                IF (TIME() > NextUpdateTimeL) AND (ProcessPercentL > 0) THEN BEGIN
                    WindowDialogG.UPDATE(1, ROUND(ProcessPercentL * 10000, 1));
                    NextUpdateTimeL := TIME() + 1000;
                END;

            UNTIL ExcelBufferG.NEXT() = 0;


        WindowDialogG.UPDATE(1, 10000);

        SLEEP(500);

        WindowDialogG.CLOSE();

    end;

    procedure SetTargetLanguageG(TargetLanguageP: Code[10]);
    begin
        TargetLanguageG := TargetLanguageP;
    end;

    var
        TargetLanguageG: Code[10];
}

