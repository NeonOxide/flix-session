use IxMonad.ixbind
pub trait IxMonad[m: Type -> Type -> Type -> Type ] {
    pub def ixreturn(e: a) : m[i, i, a]
    pub def ixbind(e: m[i, j, a], f: (a -> m[j, k, b] \ e1)) : m[i, k, b]
    pub def ixcompose(e1: m[i, j, a], e2: m[j, k, b]) : m[i, k, b] = 
        ixbind(e1, _ -> e2)
}

mod IxMonad{
    pub def >>>=(e: m[i, j, a], f: (a -> m[j, k, b] \ e1 )) : m[i, k, b]  with IxMonad[m]= ixbind(e,f)
    pub def >>>|(e1: m[i, j, a], e2: m[j, k, b]) : m[i, k, b]  with IxMonad[m]= ixcompose(e1,e2)
}