table 78605 "BAC Translation Term"
{
    Caption = 'Translation Term';
    DataClassification = AccountData;

    fields
    {
        field(10; "Project Code"; code[10])
        {
            DataClassification = AccountData;
            Caption = 'Project Code';
            Editable = false;
        }
        field(20; "Target Language"; code[10])
        {
            DataClassification = AccountData;
            Caption = 'Target Language';
            Editable = false;
        }
        field(30; "Line No."; Integer)
        {
            DataClassification = AccountData;
            Caption = 'Line No.';
        }
        field(40; Term; Text[2048])
        {
            DataClassification = AccountData;
            Caption = 'Term';
        }
        field(50; Translation; Text[2048])
        {
            DataClassification = AccountData;
            Caption = 'Translation';
        }
    }

    keys
    {
        key(PK; "Project Code", "Target Language", "Line No.")
        {
            Clustered = true;
        }
    }
}