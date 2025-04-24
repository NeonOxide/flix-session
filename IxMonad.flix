/**
 * The `IxMonad` trait represents an indexed monad, which is a generalization of monads with 
 * additional indices that track the state transitions.
 *
 * Type parameters:
 * - `m`: A higher-kinded type constructor that takes three type parameters and an effect (the monad).
 *      - `init`: The initial state
 *      - `final`: The final state
 *      - `value`: The value type
 *      - `effect`: The effect type
 *
 * Indexed monads are particularly useful for working with session types, where 
 * the indices can track protocol states.
 */
pub trait IxMonad[m: Type -> Type -> Type -> Eff -> Type] {
    /**
     * Lifts a pure value into the indexed monad.
     * The initial and final states are the same, indicating no state change.
     *
     * - `value`: The value to lift into the monad
     * - Returns a monadic value with identical initial and final states
     */
    pub def ixreturn(value: a): m[init, init, a, effect]

    /**
     * Sequential composition of indexed monadic operations.
     * Executes the first computation, then uses its result to determine the next computation.
     *
     * - `computation`: The initial monadic computation
     * - `next`: A function that takes the result of the first computation and returns the next monadic computation
     * - Returns a combined monadic computation that transitions from the initial state to the final state
     */
    pub def ixbind(computation: m[init, mid, a, effect1], next: (a -> m[mid, final, b, effect2] \ effect3)): m[init, final, b, effect1 + effect2 + effect3]

    /**
     * Sequentially composes two monadic actions, discarding the value produced by the first.
     *
     * - `first`: The first monadic computation
     * - `second`: The second monadic computation
     * - Returns a combined monadic computation that transitions from the initial state to the final state
     */
    pub def ixcompose(first: m[init, mid, a, effect1], second: m[mid, final, b, effect2]): m[init, final, b, effect1 + effect2] = 
        IxMonad.ixbind(first, _ -> second)
}

/**
 * Module containing operator functions for the indexed monad.
 */
mod IxMonad {
    /**
     * The bind operator for indexed monads.
     * Allows for more concise chaining of monadic operations. Just calls ixbind on its aruments
     *
     * - `computation`: The initial monadic computation
     * - `next`: A function that takes the result of the first computation and returns the next monadic computation
     * - Returns a combined monadic computation
     */
    pub def >>>=[m: Type -> Type -> Type -> Eff -> Type,
                 init: Type, mid: Type, a: Type, effect1: Eff, 
                 final: Type, b: Type, effect2: Eff, effect3: Eff]
                (computation: m[init, mid, a, effect1], next: (a -> m[mid, final, b, effect2] \ effect3)): m[init, final, b, effect1 + effect2 + effect3] with IxMonad[m] = 
        ixbind(computation, next)

    /**
     * The sequence operator for indexed monads.
     * Sequentially executes two monadic operations, discarding the value from the first. Just calls ixcompose on its arguments
     *
     * - `first`: The first monadic computation
     * - `second`: The second monadic computation
     * - Returns a combined monadic computation
     */
    pub def >>>|[m: Type -> Type -> Type -> Eff -> Type,
                init: Type, mid: Type, a: Type, effect1: Eff,
                final: Type, b: Type, effect2: Eff]
               (first: m[init, mid, a, effect1], second: m[mid, final, b, effect2]): m[init, final, b, effect1 + effect2] with IxMonad[m] = 
        ixcompose(first, second)
}
