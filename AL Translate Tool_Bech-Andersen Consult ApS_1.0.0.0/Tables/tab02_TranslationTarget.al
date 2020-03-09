table 78602 "BAC Translation Target"
{
    DataClassification = AccountData;
    Caption = 'Translation Target';

    fields
    {
        field(5; "Line No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Line No.';
            AutoIncrement = true;
        }
        field(10; "Project Code"; code[10])
        {
            DataClassification = AccountData;
            Caption = 'Project Code';
            Editable = false;
        }
        field(20; "Trans-Unit Id"; Text[250])
        {
            DataClassification = AccountData;
            Caption = 'Trans-Unit Id';
            Editable = false;
        }
        field(30; "Target Language"; code[10])
        {
            DataClassification = AccountData;
            Caption = 'Target Language';
            Editable = false;
        }
        field(40; "Target Language ISO code"; Text[10])
        {
            DataClassification = AccountData;
            Caption = 'Target Language ISO code';
            Editable = false;
        }
        field(50; "Source"; Text[2048])
        {
            DataClassification = AccountData;
            Caption = 'Source';
            Editable = false;
        }
        field(60; "Target"; Text[2048])
        {
            DataClassification = AccountData;
            Caption = 'Target';
            trigger OnValidate()
            var
                TransTarget: Record "BAC Translation Target";
                Instances: Integer;
                QuestionTxt: Label 'Copy the Target to all other instances?';
            begin
                TransTarget.SetRange(Source, Source);
                Instances := TransTarget.Count();
                if Target = '' then
                    exit;
                if Instances > 1 then begin
                    if CurrFieldNo > 0 then
                        if not confirm(QuestionTxt) then
                            exit;
                    TransTarget.ModifyAll(Target, Target);
                    TransTarget.ModifyAll(Translate, false);
                end;
                if Target <> '' then
                    Translate := false;
            end;

        }
        field(70; "Translate"; Boolean)
        {
            DataClassification = AccountData;
            Caption = 'Translate';
            InitValue = true;
        }
        field(80; "size-unit"; Text[10])
        {
            Caption = 'size-unit';
            DataClassification = AccountData;
        }
        field(90; "TranslateAttr"; Text[10])
        {
            Caption = 'TranslateAttr';
            DataClassification = AccountData;
        }
        field(100; "xml:space"; Text[10])
        {
            Caption = 'xml:space';
            DataClassification = AccountData;
        }
        field(110; "Max Width"; Text[10])
        {
            DataClassification = AccountData;
            Caption = 'Max Width';
        }
        field(120; "Occurrencies"; Integer)
        {
            Caption = 'Occurrencies';
            FieldClass = FlowField;
            CalcFormula = count ("BAC Translation Target" where(Source = field(Source)));
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