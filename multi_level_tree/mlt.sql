USE [master]
GO
/****** Object:  Database [mlt]    Script Date: 02/12/2012 15:14:57 ******/
CREATE DATABASE [mlt] ON  PRIMARY 
( NAME = N'mlt', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\mlt.mdf' , SIZE = 2048KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'mlt_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\mlt_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [mlt] SET COMPATIBILITY_LEVEL = 90
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [mlt].[dbo].[sp_fulltext_database] @action = 'disable'
end
GO
ALTER DATABASE [mlt] SET ANSI_NULL_DEFAULT OFF
GO
ALTER DATABASE [mlt] SET ANSI_NULLS OFF
GO
ALTER DATABASE [mlt] SET ANSI_PADDING OFF
GO
ALTER DATABASE [mlt] SET ANSI_WARNINGS OFF
GO
ALTER DATABASE [mlt] SET ARITHABORT OFF
GO
ALTER DATABASE [mlt] SET AUTO_CLOSE OFF
GO
ALTER DATABASE [mlt] SET AUTO_CREATE_STATISTICS ON
GO
ALTER DATABASE [mlt] SET AUTO_SHRINK OFF
GO
ALTER DATABASE [mlt] SET AUTO_UPDATE_STATISTICS ON
GO
ALTER DATABASE [mlt] SET CURSOR_CLOSE_ON_COMMIT OFF
GO
ALTER DATABASE [mlt] SET CURSOR_DEFAULT  GLOBAL
GO
ALTER DATABASE [mlt] SET CONCAT_NULL_YIELDS_NULL OFF
GO
ALTER DATABASE [mlt] SET NUMERIC_ROUNDABORT OFF
GO
ALTER DATABASE [mlt] SET QUOTED_IDENTIFIER OFF
GO
ALTER DATABASE [mlt] SET RECURSIVE_TRIGGERS OFF
GO
ALTER DATABASE [mlt] SET  DISABLE_BROKER
GO
ALTER DATABASE [mlt] SET AUTO_UPDATE_STATISTICS_ASYNC OFF
GO
ALTER DATABASE [mlt] SET DATE_CORRELATION_OPTIMIZATION OFF
GO
ALTER DATABASE [mlt] SET TRUSTWORTHY OFF
GO
ALTER DATABASE [mlt] SET ALLOW_SNAPSHOT_ISOLATION OFF
GO
ALTER DATABASE [mlt] SET PARAMETERIZATION SIMPLE
GO
ALTER DATABASE [mlt] SET READ_COMMITTED_SNAPSHOT OFF
GO
ALTER DATABASE [mlt] SET  READ_WRITE
GO
ALTER DATABASE [mlt] SET RECOVERY FULL
GO
ALTER DATABASE [mlt] SET  MULTI_USER
GO
ALTER DATABASE [mlt] SET PAGE_VERIFY CHECKSUM
GO
ALTER DATABASE [mlt] SET DB_CHAINING OFF
GO
USE [mlt]
GO
/****** Object:  UserDefinedFunction [dbo].[convert_integer_to_roma]    Script Date: 02/12/2012 15:14:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Ba Hong Minh
-- Create date: 2012/02/12
-- Description:	Convert sequence number to Roman value
-- 1 to I; 2 to II ...
-- =============================================
CREATE FUNCTION [dbo].[convert_integer_to_roma](@i int)
RETURNS VARCHAR(100)
AS
BEGIN
	RETURN replicate('M',@i/1000) +
	replace(replace(replace(replicate('C',@i%1000/100),replicate('C',9),'CM'),replicate('C',5),'D'),replicate('C',4),'CD') +
	replace(replace(replace(replicate('X',@i%100/10),replicate('X',9),'XC'),replicate('X',5),'L'),replicate('X',4),'XL') +
	replace(replace(replace(replicate('I',@i%10),replicate('I',9),'IX'),replicate('I',5),'V'),replicate('I',4),'IV')
END
GO
/****** Object:  UserDefinedFunction [dbo].[get_reverse_ascii]    Script Date: 02/12/2012 15:14:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Ba Hong Minh, minhdbh
-- Create date: 2012/02/12
-- Description:	Convert sequence number to Ascii value
-- 1 to A; 2 to B ...
-- =============================================
CREATE FUNCTION [dbo].[get_reverse_ascii]
(
	
	@Ascii_pattern nvarchar(30), -- Which sequence in ASCII you want is converted from number
	@seq_to_convert int -- The number value u want to convert to ASCII
)
RETURNS nvarchar(5)
AS
BEGIN
	-- Declare the return variable here
	Declare @result nvarchar(5)
	declare @patternLen int
	declare @indexchar int
	declare @prefex int
	set @patternLen=len(@Ascii_pattern)
	SET @result=''

	if (@patternLen>0) 
	begin
		--set @result=''
		set @prefex=@seq_to_convert/@patternLen
		if (@prefex>0)
		begin
			set @indexchar=cast (@seq_to_convert%@patternLen as int)
			set @result= substring(@Ascii_pattern,case @indexchar when 0 then @prefex-1 else @prefex end ,1)
			
			set @result= @result+substring(@Ascii_pattern,case @indexchar when 0 then @patternLen else @indexchar end,1)	
		end
		else
		begin
			set @indexchar=cast (@seq_to_convert%@patternLen as int)
			set @result= substring(@Ascii_pattern,case @indexchar when 0 then @patternLen else @indexchar end ,1)
		
		end
	end

	
	
	return @result

END
GO
/****** Object:  Table [dbo].[TreeDataTbl]    Script Date: 02/12/2012 15:14:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TreeDataTbl](
	[Tree_ID] [int] IDENTITY(1,1) NOT NULL,
	[Tree_Name] [nvarchar](100) NOT NULL,
	[Parent_ID] [int] NOT NULL,
	[Seq_index] [varchar](5) NOT NULL,
	[Full_index] [varchar](50) NOT NULL,
 CONSTRAINT [PK_TreeDataTbl] PRIMARY KEY CLUSTERED 
(
	[Tree_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  UserDefinedFunction [dbo].[get_seq_by_level]    Script Date: 02/12/2012 15:14:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Ba Hong Minh, minhdbh
-- Create date: 2012/02/12
-- Description:	Convert sequence number to Seqeunce value
-- If level= 1; use Sequence value from A..Z
-- If level= 2; use Roma Sequence value 
-- If level= 3; use oridinal number
-- =============================================
CREATE FUNCTION [dbo].[get_seq_by_level]
(
	-- Add the parameters for the function here
	@treelevel int,
	@seq_id int

)
RETURNS nvarchar(5)
AS
BEGIN

	if @treelevel=0
	begin
		return dbo.get_reverse_ascii('ABCDEFGHIJKLMNOPQRSTUVWXYZ',@seq_id)
	end


	if @treelevel=1
	begin
		return dbo.[convert_integer_to_roma](@seq_id)
	end

	if @treelevel>=2
	begin
		return cast(@seq_id as varchar)
	end
	return ''

END
GO
/****** Object:  UserDefinedFunction [dbo].[count_tree_full_index]    Script Date: 02/12/2012 15:14:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Ba Hong Minh
-- Create date: 2012/02/12
-- Description:	Caculate full path to tree node, show as a ditionary: A.I.1, B.I.2...
-- =============================================
CREATE FUNCTION [dbo].[count_tree_full_index]
(
	
	@tree_node_id int
)
RETURNS varchar(20)
AS
BEGIN
	
	declare @result varchar(20)
	set @result =''
	declare @node_seq_index varchar(5)
	
	
	
	DECLARE @parentID int

	select @node_seq_index=isnull(Seq_index,''),@parentID=isnull(Parent_ID,0) from dbo.TreeDataTbl where Tree_ID=@tree_node_id


	set @result=@node_seq_index

	  WHILE @parentID > 0
		BEGIN
		  SELECT @tree_node_id = @parentID
		  select @node_seq_index=isnull(Seq_Index,''),@parentID=Parent_ID from dbo.TreeDataTbl where Tree_ID=@tree_node_id


			set @result=@node_seq_index+'.'+@result
		END
	  RETURN @result

END
GO
/****** Object:  UserDefinedFunction [dbo].[check_parent]    Script Date: 02/12/2012 15:14:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Ba Hong Minh
-- Create date: 2012/02/12
-- Description:	Check a node if it'is a child (even grand-child) of a Parent Node
-- =============================================
CREATE FUNCTION [dbo].[check_parent]
(
	-- Add the parameters for the function here
	@node_id int,
	@parent_id int
)
RETURNS int
--0: If node_id is not a child of parent_id
AS
BEGIN
	-- Declare the return variable here
	declare @resust int
	set @resust=0
	declare @parent int
	declare @tmp_node_id int
	set @tmp_node_id=@node_id
	if @node_id<>@parent_id
		begin
		select @parent=Parent_ID from dbo.TreeDataTbl where Tree_ID=@tmp_node_id
		set @tmp_node_id=@parent
		while @parent<>@parent_id and @parent>0
		begin
			select @parent=Parent_id from dbo.TreeDataTbl where Tree_ID=@tmp_node_id
			set @tmp_node_id=@parent
		end
		if @parent=@parent_id begin set @resust=1 end
	end
	else
	begin
		set @resust=1
	end
	return @resust

END
GO
/****** Object:  UserDefinedFunction [dbo].[count_tree_level]    Script Date: 02/12/2012 15:14:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Ba Hong Minh
-- Create date: 2012/02/12
-- Description:	Test and return the level of a tree-node
-- Value of level start by 0; Level = 0: Root
-- =============================================
CREATE FUNCTION [dbo].[count_tree_level]
(
	-- tree node id to test
	@tree_id int
)
RETURNS int
AS
BEGIN
	
	DECLARE @parentID int
	Declare @tree_level int
	Set @tree_level=-1
	  SELECT @parentID = isnull(Parent_ID,0)
	  FROM dbo.TreeDataTbl
	  WHERE Tree_ID = @tree_id
	  if @ParentID>=0 set @tree_level=0
	  WHILE @parentID >= 0
		BEGIN
		 
		  SELECT @tree_id = @parentID
		   set @parentID=-1
		  SELECT @parentID = Parent_ID
		  FROM dbo.TreeDataTbl
		  WHERE Tree_ID = @tree_id
		  if  @parentID>=0 SET @tree_level=@tree_level+1
		END
	  RETURN @tree_level

END
GO
/****** Object:  StoredProcedure [dbo].[view_tree]    Script Date: 02/12/2012 15:15:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Ba Hong Minh
-- Create date: 2012/2/12
-- Description:	Select and view tree by main dictionary
-- =============================================
CREATE PROCEDURE [dbo].[view_tree]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		[Full_index]
      ,[Tree_Name]
	  FROM [mlt].[dbo].[TreeDataTbl]
	ORDER BY [Full_index]

END
GO
/****** Object:  StoredProcedure [dbo].[view_human_tree]    Script Date: 02/12/2012 15:15:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Ba Hong Minh
-- Create date: 2012/2/12
-- Description:	Select and view tree by main dictionary
-- =============================================
CREATE PROCEDURE [dbo].[view_human_tree]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		[Full_index]
      ,REPLICATE(' ',3*dbo.count_tree_level(Tree_ID))+'+-- '+[Tree_Name] as TreeDes
	  FROM [mlt].[dbo].[TreeDataTbl]
	ORDER BY [Full_index]

END
GO
/****** Object:  StoredProcedure [dbo].[insert_tree_node]    Script Date: 02/12/2012 15:15:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Ba Hong Minh, minhdbh
-- Create date: 2012/02/12
-- Description:	Insert new tree Node
-- If Parent_ID =0 or null: Node is root
-- =============================================
CREATE PROCEDURE [dbo].[insert_tree_node]
	
	@tree_name nvarchar(100),
	@parent_ID int
AS
BEGIN
	
	SET NOCOUNT ON;
	Declare @full_index varchar(30)
	Select  @full_index=Full_index   from dbo.TreeDataTbl where Tree_ID=isnull(@parent_ID,0)
	Declare @Tree_ID int
	
	DECLARE @New_Seq_Index varchar(5) -- By default, when adding new node to tree, it appears at last branch of tree 
	SET @New_Seq_Index=''

	DECLARE @tree_node_level int 
	DECLARE @total_child_in_level int --Count total current child node at this level

	SET @tree_node_level =case @parent_ID when 0 then 0 else [dbo].[count_tree_level](isnull(@parent_ID,0))+1 end
	
	Select @total_child_in_level=count(*) from dbo.TreeDataTbl where Parent_ID=isnull(@parent_ID,0)
 
	
	Set @New_Seq_Index=[dbo].[get_seq_by_level](@tree_node_level,@total_child_in_level+1)


	INSERT INTO [dbo].[TreeDataTbl]
           ([Tree_Name]
           ,Parent_ID
           ,[Seq_Index]
           ,[Full_Index])
     VALUES
           (@tree_name
           ,isnull(@parent_ID,0)
           ,@New_Seq_Index
           ,'')
	SET @Tree_ID=@@IDENTITY
	
	update dbo.TreeDataTbl set Full_index=[dbo].[count_tree_full_index](@Tree_ID)
	from dbo.TreeDataTbl where Tree_ID=@Tree_ID


	

	
END
GO
/****** Object:  StoredProcedure [dbo].[move_node_up]    Script Date: 02/12/2012 15:15:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Ba Hong Minh
-- Create date: 2012/02/12
-- Description:	This SP will move a node to up level, it re-generate Index also
-- =============================================
CREATE PROCEDURE [dbo].[move_node_up] 
	
	@tree_id int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @Parent_ID int
	Declare @seq_index varchar(5)
	Declare @old_full_index varchar(100)
	select @Parent_ID=isnull(Parent_ID,0),@seq_index=Seq_index,@old_full_index=Full_index from dbo.TreeDataTbl where Tree_ID=@tree_id


	Declare @Tree_node_up int --Tree node ID, upper to slected node
	Declare @Seq_index_up varchar(5) --Tree node Seq_index, upper to selected node
	SET @Tree_node_up=0
	
	
	--Declare @tree_level_up int
	select top (1) @Tree_node_up=dbo.TreeDataTbl.Tree_ID,@Seq_index_up=Seq_index from dbo.TreeDataTbl 
	where Full_index<@old_full_index and Parent_ID=isnull(@Parent_ID,0)
	order by Full_index desc

	IF @Tree_node_up>0
	BEGIN
		--SET @Seq_index_up=dbo.[count_tree_level](@Tree_node_up)

		
			Update dbo.TreeDataTbl Set Seq_index=@Seq_index_up Where Tree_ID=@tree_id
			Update dbo.TreeDataTbl Set Seq_Index=@seq_index Where Tree_ID=@Tree_node_up


			
			
			
			update dbo.TreeDataTbl set Full_Index=seqTbl.seq_full_index
			from dbo.TreeDataTbl,
			(
				select Tree_ID, [dbo].[count_tree_full_index](Tree_ID) seq_full_index from dbo.TreeDataTBl where dbo.check_parent(Tree_ID,@Tree_node_up)=1
			) seqTbl
			where TreeDataTbl.Tree_ID=seqTbl.Tree_ID
			
		
			update dbo.TreeDataTbl set Full_Index=seqTbl.seq_full_index
			from dbo.TreeDataTbl,
			(
				select Tree_ID, [dbo].[count_tree_full_index](Tree_ID) seq_full_index from dbo.TreeDataTBl where dbo.check_parent(Tree_ID,@Tree_ID)=1
			) seqTbl
			where TreeDataTbl.Tree_ID=seqTbl.Tree_ID
			


		
	END


END
GO
/****** Object:  StoredProcedure [dbo].[move_node_down]    Script Date: 02/12/2012 15:15:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Ba Hong Minh
-- Create date: 2012/02/12
-- Description:	This SP will move a node to down level, it re-generate Index also
-- =============================================
CREATE PROCEDURE [dbo].[move_node_down] 
	
	@tree_id int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @Parent_ID int
	Declare @seq_index varchar(5)
	Declare @old_full_index varchar(100)
	select @Parent_ID=isnull(Parent_ID,0),@seq_index=Seq_index,@old_full_index=Full_index from dbo.TreeDataTbl where Tree_ID=@tree_id


	Declare @Tree_node_down int --Tree node ID, upper to slected node
	Declare @Seq_index_down varchar(5) --Tree node Seq_index, upper to selected node
	SET @Tree_node_down=0
	
	
	--Declare @tree_level_up int
	select top (1) @Tree_node_down=dbo.TreeDataTbl.Tree_ID,@Seq_index_down=Seq_index from dbo.TreeDataTbl 
	where Full_index>@old_full_index and Parent_ID=isnull(@Parent_ID,0)
	order by Full_index asc

	IF @Tree_node_down>0
	BEGIN
		--SET @Seq_index_up=dbo.[count_tree_level](@Tree_node_up)

		
			Update dbo.TreeDataTbl Set Seq_index=@Seq_index_down Where Tree_ID=@tree_id
			Update dbo.TreeDataTbl Set Seq_Index=@seq_index Where Tree_ID=@Tree_node_down

			
			update dbo.TreeDataTbl set Full_Index=seqTbl.seq_full_index
			from dbo.TreeDataTbl,
			(
				select Tree_ID, [dbo].[count_tree_full_index](Tree_ID) seq_full_index from dbo.TreeDataTBl where dbo.check_parent(Tree_ID,@Tree_node_down)=1
			) seqTbl
			where TreeDataTbl.Tree_ID=seqTbl.Tree_ID
			
		
			update dbo.TreeDataTbl set Full_Index=seqTbl.seq_full_index
			from dbo.TreeDataTbl,
			(
				select Tree_ID, [dbo].[count_tree_full_index](Tree_ID) seq_full_index from dbo.TreeDataTBl where dbo.check_parent(Tree_ID,@Tree_ID)=1
			) seqTbl
			where TreeDataTbl.Tree_ID=seqTbl.Tree_ID
		
	END

END
GO
/****** Object:  StoredProcedure [dbo].[remove_node]    Script Date: 02/12/2012 15:15:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Ba Hong Minh
-- Create date: 2012/02/12
-- Description:	This SP will remove a node, it re-generate Index also
-- =============================================
CREATE PROCEDURE [dbo].[remove_node]
	-- Add the parameters for the stored procedure here
	@tree_id int
    
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @ParentID int
	Declare @seq_index varchar(5)
	
	select @ParentID=isnull(Parent_ID,0),@seq_index=Seq_index from dbo.TreeDataTbl where Tree_ID=@tree_id

	--Find all node is belong to Selected node and remove it!
	CREATE TABLE #tmpDeletedNode 
	( 
		 Tree_ID INT, 
		 Parent_ID INT
	)
	INSERT INTO #tmpDeletedNode
	SELECT Tree_id,Parent_id from dbo.TreeDataTbl
	where dbo.check_parent(Tree_ID,@tree_id)=1
	Delete from TreeDataTbl where Tree_ID in
		(Select Tree_ID from #tmpDeletedNode)
	Drop Table #tmpDeletedNode
	
    -- Insert statements for procedure here
	CREATE TABLE #tmptree 
	( 
		 tree_id INT, 
		 seq_index NVARCHAR(5)
	)


	 INSERT INTO #tmptree 
	 select 	Tree_ID,dbo.get_seq_by_level(tree_level,rid) seq_index from
	 (
		select Tree_ID, Parent_ID, dbo.count_tree_level(tree_id) tree_level,  ROW_NUMBER() over (order by seq_index) as rid from dbo.TreeDataTbl 
		where Parent_ID =@ParentID
				
	 ) as NewSeqTbl
	 
	 
	 update dbo.TreeDataTbl set Seq_index=#tmptree.seq_index
	 from dbo.TreeDataTbl,#tmptree
	 where TreeDataTbl.Tree_ID=#tmptree.Tree_ID	 
	DROP table #tmptree

	update dbo.TreeDataTbl set Full_index=seqTbl.full_index
	from dbo.TreeDataTbl,
	(
	select Tree_ID, [dbo].[count_tree_full_index](Tree_ID) full_index from TreeDataTbl where dbo.check_parent(Tree_ID,@ParentID)=1
	) seqTbl
	where TreeDataTbl.Tree_ID=seqTbl.Tree_ID
			

	
    
END
GO
