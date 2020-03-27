page 78608 "BAC Gen. Translation Terms"
{
    Caption = 'General Translation Terms';
    PageType = List;
    SourceTable = "BAC Gen. Translation Term";
    AutoSplitKey = true;
    UsageCategory = Tasks;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(Language)
            {
                field(LanguageFilter; LangFilter)
                {
                    Caption = 'Language Filter';
                    ApplicationArea = All;
                    TableRelation = Language where("BAC ISO code" = filter('<>'''''));
                    trigger OnValidate()
                    begin
                        if LangFilter <> '' then
                            SetFilter("Target Language", LangFilter)
                        else
                            SetRange("Target Language");
                        CurrPage.Update(false);
                    end;
                }
            }
            repeater(GroupName)
            {
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                }
                field(Term; Term)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the term to hardcode for translation. E.g. ''Journal'' must be translated to ''Worksheet''. Every instance of the term will be replaced with the translation.';
                }
                field(Translation; Translation)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the translation to be inserted for the term. E.g. ''Journal'' must be translated to ''Worksheet''. Every instance of the term will be replaced with the translation.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("Import From Excel (Term, Translation)")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Import;

                trigger OnAction();
                var
                    ImportGeneralTranslationTermsRepL: Report "ImportGeneralTranslationTerms";
                begin
                    IF LangFilter = '' THEN
                        Error('You have to choose Language Filter!')
                    ELSE BEGIN
                        ImportGeneralTranslationTermsRepL.SetTargetLanguageG(LangFilter);
                        ImportGeneralTranslationTermsRepL.Run();
                    end;
                end;
            }
        }
    }

    var
        LangFilter: Code[10];

}