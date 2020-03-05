report 78600 "ImportGeneralTranslationTerms"
{
    //>>GPI-46986-T9H2AA-13.12.2019.-BRA-
    //   - New object

    CaptionML = ENU = 'Import General Translation Terms',
                SRM = 'Import General Translation Terms';
    ProcessingOnly = true;

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
                        field(FileNameG; FileNameG)
                        {
                            CaptionML = ENU = 'Workbook File Name',
                                        SRM = 'Ime datoteke';
                            Editable = false;

                            trigger OnAssistEdit();
                            begin
                                RequestFile();

                                SheetNameG := ExcelBufferG.SelectSheetsName(ServerFileNameG);
                            end;

                            trigger OnValidate();
                            begin
                                FileNameOnAfterValidate();
                            end;
                        }
                        field(SheetNameG; SheetNameG)
                        {
                            CaptionML = ENU = 'Worksheet Name',
                                        SRM = 'Ime radnog lista';
                            Editable = false;

                            trigger OnAssistEdit();
                            begin
                                IF ServerFileNameG = '' THEN
                                    RequestFile();

                                SheetNameG := ExcelBufferG.SelectSheetsName(ServerFileNameG);
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
            FileNameG := '';
            SheetNameG := '';
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
        ExcelBufferG.DELETEALL;
    end;

    trigger OnPreReport();
    begin
        ExcelBufferG.DELETEALL;

        ExcelBufferG.OpenBook(ServerFileNameG, SheetNameG);
        ExcelBufferG.ReadSheet();

        ImportDataFromExcel();
    end;

    var
        ExcelBufferG: Record "Excel Buffer" temporary;
        FileManagementG: Codeunit "File Management";
        WindowDialogG: Dialog;
        FileNameG: Text;
        SheetNameG: Text[250];
        ServerFileNameG: Text;
        ImportExcelFileTxt: TextConst ENU = 'Import Excel File', SRM = 'Uvoz Excel datoteke';
        MustEnterFileNameErr: TextConst ENU = 'You must enter a file name.', SRM = 'Morate uneti ime fajla.';
        ProcessingDataTxt: TextConst ENU = 'Importing entris from Excel...\', SRM = 'Uvoz stavki iz Excela...\';
        StatusTxt: TextConst ENU = 'Status:             @1@@@@@@@@@@@@', SRM = 'Status:             @1@@@@@@@@@@@@';
        ImportSuccessfulTxt: TextConst ENU = 'Import successfull', SRM = 'Uvoz stavki uspešan';
        ItemNoG: Code[20];

    local procedure RequestFile();
    begin
        IF FileNameG <> '' THEN
            ServerFileNameG := FileManagementG.UploadFile(ImportExcelFileTxt, FileNameG)
        ELSE
            ServerFileNameG := FileManagementG.UploadFile(ImportExcelFileTxt, '.xlsx');

        ValidateServerFileName();

        FileNameG := FileManagementG.GetFileName(ServerFileNameG);
    end;

    local procedure FileNameOnAfterValidate();
    begin
        RequestFile();
    end;

    local procedure ValidateServerFileName();
    begin
        IF ServerFileNameG = '' THEN BEGIN
            FileNameG := '';
            SheetNameG := '';
            ERROR(MustEnterFileNameErr);
        END;
    end;

    procedure ImportDataFromExcel();
    var
        ProcessPercentL: Decimal;
        NumberOfRowsL: Integer;
        NextUpdateTimeL: Time;
        LineNoL: Integer;
        ManufacturerItemNoL: Code[50];
        QuantityPerL: Decimal;
        GenTransTermLastL: Record "BAC Gen. Translation Term";
        GenTransTermCheckL: Record "BAC Gen. Translation Term";
        GenTransTermL: Record "BAC Gen. Translation Term";
        RowNoL: Integer;
        LastRowNoL: Integer;
        TermL: Text;
        TranslationL: Text;
    begin
        WindowDialogG.OPEN(ProcessingDataTxt + StatusTxt);
        NextUpdateTimeL := TIME + 1000;

        IF ExcelBufferG.FINDLAST THEN
            NumberOfRowsL := ExcelBufferG."Row No.";

        GenTransTermLastL.RESET;
        GenTransTermLastL.SetRange("Target Language", TargetLanguageG);
        IF GenTransTermLastL.FINDLAST THEN
            LineNoL := GenTransTermLastL."Line No."
        ELSE
            LineNoL := 0;

        ExcelBufferG.RESET;
        //ExcelBufferG.SETRANGE("Column No.", 4);
        //ExcelBufferG.SETFILTER("Row No.", '%1..', 2);
        //RowNoL := 1;

        IF ExcelBufferG.FINDSET THEN
            REPEAT
                IF ExcelBufferG."Column No." = 1 THEN BEGIN
                    TermL := ExcelBufferG."Cell Value as Text";
                end else begin
                    TranslationL := ExcelBufferG."Cell Value as Text";

                    GenTransTermCheckL.Reset;
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
                IF (TIME > NextUpdateTimeL) AND (ProcessPercentL > 0) THEN BEGIN
                    WindowDialogG.UPDATE(1, ROUND(ProcessPercentL * 10000, 1));
                    NextUpdateTimeL := TIME + 1000;
                END;

            UNTIL ExcelBufferG.NEXT = 0;


        WindowDialogG.UPDATE(1, 10000);

        SLEEP(500);

        WindowDialogG.CLOSE;

    end;

    procedure SetTargetLanguageG(TargetLanguageP: Code[20]);
    begin
        TargetLanguageG := TargetLanguageP;
    end;

    var
        TargetLanguageG: Code[20];
}

