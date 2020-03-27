page 78605 "BAC Trans Target Factbox"
{
    PageType = CardPart;
    SourceTable = "BAC Translation Target";
    Caption = 'Translation Target Factbox';
    Editable = false;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                ShowCaption = false;
                field(Instances; Counter)
                {
                    Caption = 'Instances';
                    ApplicationArea = All;
                }
            }
        }
    }

    var
        Counter: Integer;

    trigger OnAfterGetRecord()
    var
        TransTarget: Record "BAC Translation Target";
    begin
        TransTarget.SetRange(Source, Source);
        Counter := TransTarget.Count();
    end;
}