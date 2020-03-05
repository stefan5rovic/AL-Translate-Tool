pageextension 78600 "BAC Languages Ext" extends Languages
{
    layout
    {
        addafter("Windows Language ID")
        {
            field("BAC ISO code"; "BAC ISO code")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}