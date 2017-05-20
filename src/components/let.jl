function parse_kw(ps::ParseState, ::Type{Val{Tokens.LET}})
    startbyte = ps.t.startbyte
    start_col = ps.t.startpos[2] + 4

    # Parsing
    ret = EXPR(Let, [INSTANCE(ps)], -startbyte)
    format_kw(ps)
        
    
    @default ps @closer ps comma @closer ps block while !closer(ps)
        @catcherror ps startbyte a = parse_expression(ps)
        push!(ret.args, a)
        if ps.nt.kind == Tokens.COMMA
            next(ps)
            push!(ret.args, INSTANCE(ps))
            format_comma(ps)
        end
    end
    @catcherror ps startbyte block = @default ps parse_block(ps, start_col)

    # Construction
    push!(ret.args, block)
    next(ps)
    push!(ret.args, INSTANCE(ps))
    ret.span += ps.nt.startbyte

    # Linting
    # let span = startbyte + ret.head.span
    #     for (i, a) in enumerate(args)
    #         if !(a isa EXPR && a.head isa OPERATOR{1})
    #             push!(ps.diagnostics, Diagnostic{Diagnostics.LetNonAssignment}(span:a.head))
    #         end
    #         span += a.span + ret.punctuation[i].span
    #     end
    # end
    return ret
end
