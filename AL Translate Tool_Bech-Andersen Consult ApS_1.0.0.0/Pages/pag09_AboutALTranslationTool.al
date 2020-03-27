page 78609 "BAC About AL Translation Tool"
{
    Caption = 'About AL Translation Tool';
    PageType = CardPart;
    SourceTable = "BAC Translation Setup";
    ShowFilter = false;

    layout
    {
        area(Content)
        {
            group("About AL Translation Tool")
            {

                Caption = 'About AL Translation Tool';
                InstructionalText = 'Open-Source AL Translate Tool. Source code can be located at https://github.com/peikba/AL-Translate-Tool.';
            }
            grid("App")
            {
                ShowCaption = false;
                GridLayout = Columns;
                group("Group2")
                {
                    ShowCaption = false;
                    field("Version"; AppVersion)
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field(AppName; ApplicationName)
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field(AppPublisher; ApplicationPublisher)
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                }
            }
        }
    }

    var
        AppVersion: Text[10];
        ApplicationName: Text;
        ApplicationPublisher: Text;
        AppModuleInfo: ModuleInfo;

    trigger OnOpenPage()
    begin
        if NavApp.GetCurrentModuleInfo(AppModuleInfo) then begin
            AppVersion := format(AppModuleInfo.AppVersion());
            ApplicationName := AppModuleInfo.Name();
            ApplicationPublisher := AppModuleInfo.Publisher();
        end;
    end;
}