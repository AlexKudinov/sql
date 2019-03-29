USE [msdb]
GO

/****** Object:  Job [RebuildDBs]    Script Date: 29.03.2019 9:57:57 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 29.03.2019 9:57:57 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'RebuildDBs', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [1]    Script Date: 29.03.2019 9:57:57 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @Execute nvarchar(max) = ''Y''
DECLARE @RC int
DECLARE @Databases nvarchar(max) = ''USER_DATABASES'' --Select databases. The keywords SYSTEM_DATABASES, USER_DATABASES, ALL_DATABASES, and AVAILABILITY_GROUP_DATABASES are supported. The hyphen character (-) is used to exclude databases, and the percent character (%) is used for wildcard selection. All of these operations can be combined by using the comma (,).
DECLARE @FragmentationLow nvarchar(max) = ''INDEX_REORGANIZE''
DECLARE @FragmentationMedium nvarchar(max) = ''INDEX_REBUILD_ONLINE,INDEX_REORGANIZE''
DECLARE @FragmentationHigh nvarchar(max) = ''INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE''
DECLARE @FragmentationLevel1 int = 5 
DECLARE @FragmentationLevel2 int = 15
DECLARE @PageCountLevel int = 8
DECLARE @SortInTempdb nvarchar(max) = ''Y''
DECLARE @MaxDOP int
DECLARE @FillFactor int = 90
DECLARE @PadIndex nvarchar(max)
DECLARE @LOBCompaction nvarchar(max) = ''Y''
DECLARE @UpdateStatistics nvarchar(max) = NULL
DECLARE @OnlyModifiedStatistics nvarchar(max) = ''Y''
DECLARE @StatisticsSample int = 100
DECLARE @StatisticsResample nvarchar(max) = ''N''
DECLARE @PartitionLevel nvarchar(max) = ''Y''
DECLARE @MSShippedObjects nvarchar(max) = ''N''
DECLARE @Indexes nvarchar(max)
DECLARE @TimeLimit int
DECLARE @Delay int
DECLARE @WaitAtLowPriorityMaxDuration int
DECLARE @WaitAtLowPriorityAbortAfterWait nvarchar(max)
DECLARE @AvailabilityGroups nvarchar(max)
DECLARE @LockTimeout int
DECLARE @LogToTable nvarchar(max) = ''N''
----------------------------------------------------------------
------If @LogToTable = Y then uncomment theese string:
--truncate table [master].[dbo].[CommandLog]
---------------------------------------------------------------
EXECUTE @RC = [master].[dbo].[IndexOptimize] 
   @Databases 
  ,@FragmentationLow
  ,@FragmentationMedium
  ,@FragmentationHigh
  ,@FragmentationLevel1
  ,@FragmentationLevel2
  ,@PageCountLevel
  ,@SortInTempdb
  ,@MaxDOP
  ,@FillFactor
  ,@PadIndex
  ,@LOBCompaction
  ,@UpdateStatistics
  ,@OnlyModifiedStatistics
  ,@StatisticsSample
  ,@StatisticsResample
  ,@PartitionLevel
  ,@MSShippedObjects
  ,@Indexes
  ,@TimeLimit
  ,@Delay
  ,@WaitAtLowPriorityMaxDuration
  ,@WaitAtLowPriorityAbortAfterWait
  ,@AvailabilityGroups
  ,@LockTimeout
  ,@LogToTable
  ,@Execute', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Weekly_Sat1700', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=64, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20170315, 
		@active_end_date=99991231, 
		@active_start_time=170000, 
		@active_end_time=235959, 
		@schedule_uid=N'a4d5a6fb-236d-4091-af64-6a5fab1dd498'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


