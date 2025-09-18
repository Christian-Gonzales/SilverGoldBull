report 50004 "JobQueueStatus"
{
    Caption = 'Job Queue Status';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Job Queue Entry"; "Job Queue Entry")
        {
            RequestFilterFields = Status;

            trigger OnAfterGetRecord()
            var
            begin
                if "Job Queue Entry".GetFilter(Status) = '' then
                    "Job Queue Entry".SetFilter(Status, '%1', "Job Queue Entry".Status::Error);
                SetStatus(ChangeToStatus);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                field(ChangeToStatus; ChangeToStatus)
                {
                    Caption = 'Change status to:';
                    ApplicationArea = All;
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }

        trigger OnOpenPage()
        begin
        end;
    }
    var
        ChangeToStatus: Option Ready,"In Process",Error,"On Hold",Finished,"On Hold with Inactivity Timeout";
}
