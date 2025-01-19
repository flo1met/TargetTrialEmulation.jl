"""
    ITT(df::DataFrame)

Estimate intention-to-treat effect.

# Keyword Arguments

- `df::DataFrame`: DataFrame with columns `:id`, `:period`, `:eligible`, `:treatment`.

# Output

- `model`: GLM model.

# Example

"""

#### ITT: estimate intetion-to-treat effect

# necessary packages
#

## todo
# - add example (when the function is ready and example DF is created)

function ITT(df::DataFrame)
    df = convert_to_arrow(df)
    df = IPW(df)
    out = seqtrial(df)
    df_seq = dict_to_df(out)

    model = glm(@formula(outcome ~ baseline_treatment + trialnr + (trialnr^2) + fup + (fup^2) + catvarA + catvarB + catvarC + nvarA + nvarB + nvarC), df_seq, Binomial(), LogitLink(), wts = df_seq.IPW)

    return model
end