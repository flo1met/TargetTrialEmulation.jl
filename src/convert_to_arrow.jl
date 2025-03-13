"""
    convert_to_arrow(df::DataFrame)

Convertes a DataFrame to an Arrow Table
"""

#### convert_to_arrow
## convertes a DataFrame to an Arrow Table



function convert_to_arrow(df::DataFrame, id_var::Symbol)

    tempdir = mktempdir() # create temp dir for .arrow
    arrow_file = joinpath(tempdir, "df.arrow")
    Arrow.write(arrow_file, df) # write arrow file
    empty!(df) # delete orig DF
    
    df = DataFrame(Arrow.Table(arrow_file)) # reread DF as arrow    

    return df
end
