

select 
    --[Db Schema].TABLE_SCHEMA [Table Schema], 
    [Tables].name [Table Name], 
    [Table Columns].name [Column Name], 
    [Table Columns].is_nullable [is_nullable], 
    [Table Columns].is_identity [is_identity], 
    --[Table Columns].encryption_algorithm_name, 
    --[Table Columns].encryption_type_desc, 
    case when cek.name is null then null else cek.name end as CEK_Name, 
    [Column Type].name [data_type], 
    cast
        (case when [Column Type].name = 'text'
            then null
            else 
                case when [Table Columns].precision=0 and [Column Type].name <> 'text'
                    then [Table Columns].max_length 
                    else null 
                end
            end
        as smallint) [max_length], 
    cast(case when [Table Columns].precision>0 and [Column Type].precision=[Column Type].scale 
            then [Table Columns].precision else null end as tinyint) [precision], 
    cast(case when [Table Columns].precision>0 and [Column Type].precision=[Column Type].scale 
            then [Table Columns].scale else null end as tinyint) [scale], 
    cast(case when [Table Columns].is_identity=1 
            then seed_value else null end as sql_variant) [seed_value], 
    cast(case when [Table Columns].is_identity=1 
            then increment_value else null end as sql_variant) [increment_value], 
    cast(case when [Table Columns].default_object_id>0 
            then definition else null end as nvarchar(4000)) [default_value] 
from INFORMATION_SCHEMA.TABLES [Db Schema] 
    join sys.objects [Tables] on [Db Schema].TABLE_SCHEMA = schema_name([Tables].[schema_id]) 
        and [Db Schema].TABLE_NAME = [Tables].name
    join sys.columns [Table Columns] on [Tables].object_id=[Table Columns].object_id 
    left join sys.column_encryption_keys cek 
        on [Table Columns].column_encryption_key_id = CEK.column_encryption_key_id
    left join sys.identity_columns id on [Tables].object_id=id.object_id 
    join sys.types [Column Type] on [Table Columns].system_type_id=[Column Type].system_type_id 
        and [Column Type].system_type_id=[Column Type].user_type_id 
    left join sys.default_constraints d on [Table Columns].default_object_id=d.object_id 
where [Tables].type='u' and [TABLE_NAME]='LEVELAPP_NS_BOOSTERS'
order by [Table Schema], [Table Name] 
--for json auto, root('temp_BATCH')

