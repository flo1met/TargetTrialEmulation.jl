"""
    convert_to_arrow(df::DataFrame)

Convertes a DataFrame to an Arrow Table
"""

#### convert_to_arrow
## convertes a DataFrame to an Arrow Table
### sorts DF before, for loop to work correctly

# TODO: dont saver and load, convert df to arrow table

function convert_to_arrow(df::DataFrame)
    #print(issorted(df, :period))
    sort!(df, :period) # bring period in right order for loop
    #print(issorted(df, :period))

    tempdir = mktempdir() # create temp dir for .arrow
    arrow_file = joinpath(tempdir, "df.arrow")
    Arrow.write(arrow_file, df) # write arrow file
    empty!(df) # delete orig DF
    
    df = DataFrame(Arrow.Table(arrow_file)) # reread DF as arrow
    #print(issorted(df, :period))

    #sort!(df, :id, :period)

    return df
end

###
# is df a sorted DF?

# idvar = :id
