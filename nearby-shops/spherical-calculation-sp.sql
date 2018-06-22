USE [Locations]
GO

/****** Object:  StoredProcedure [dbo].[Spherical_Calculation]    Script Date: 2018-06-22 5:38:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Ben Simpson
-- Create date: 2018-06-21
-- Description:	This procedure returns items in chosen category ordered by distance
-- inputs > category, lat, lng and radius
-- output > distance, location, address
-- =============================================
CREATE PROCEDURE [dbo].[Spherical_Calculation] (
	@category VARCHAR(50),				--Input parameter ,  category to query
	@lat VARCHAR(50),					--Input parameter ,  latitude origin
	@lng VARCHAR(50),					--Input parameter ,  longitude origin
	@radius INT,						--Input parameter ,  radius (in km)
	@single BIT							-- Show closest or all in category
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT TOP (CASE WHEN @single = 1 THEN 1 ELSE 10000000 END) Id, Location, Address, distance FROM
		(SELECT Id, Location, Address,
			(6378137 * 2 * (
				ATN2(
				  SQRT(
					(SIN(((Latitude - CAST(@lat AS DECIMAL(18,14))) * PI() / 180) / 2) * SIN(((Latitude - CAST(@lat AS DECIMAL(18,14))) * PI() / 180) / 2) +
					  COS((CAST(@lat AS DECIMAL(18,14))) * PI() / 180) * COS((Latitude) * PI() / 180) *
					  SIN(((Longitude - CAST(@lng AS DECIMAL(18,14))) * PI() / 180) / 2) * SIN(((Longitude - CAST(@lng AS DECIMAL(18,14))) * PI() / 180) / 2)
					)
				  ), 
				  SQRT(
					1 - (SIN(((Latitude - CAST(@lat AS DECIMAL(18,14))) * PI() / 180) / 2) * SIN(((Latitude - CAST(@lat AS DECIMAL(18,14))) * PI() / 180) / 2) +
					COS((CAST(@lat AS DECIMAL(18,14))) * PI() / 180) * COS((Latitude) * PI() / 180) *
					SIN(((Longitude - CAST(@lng AS DECIMAL(18,14))) * PI() / 180) / 2) * SIN(((Longitude - CAST(@lng AS DECIMAL(18,14))) * PI() / 180) / 2))
				  )
				)
			  )
			) distance
		FROM Location
		WHERE CategoryId = @category) lbc
	WHERE distance < @radius
	ORDER BY distance
END

GO


