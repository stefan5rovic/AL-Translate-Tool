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
                field(LanguageFilter; LanguageFilter)
                {
                    Caption = 'Language Filter';
                    TableRelation = Language where("BAC ISO code" = filter('<>'''''));
                    trigger OnValidate()
                    begin
                        if LanguageFilter <> '' then
                            SetFilter("Target Language", LanguageFilter)
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
                //RunObject = report "ImportGeneralTranslationTerms";
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction();
                var
                    ImportGeneralTranslationTermsRepL: Report "ImportGeneralTranslationTerms";
                begin
                    IF LanguageFilter = '' THEN
                        Error('You have to choose Language Filter!')
                    ELSE BEGIN
                        ImportGeneralTranslationTermsRepL.SetTargetLanguageG(LanguageFilter);
                        ImportGeneralTranslationTermsRepL.Run();
                    end;
                end;
            }
        }
    }

    var
        LanguageFilter: Code[10];

}