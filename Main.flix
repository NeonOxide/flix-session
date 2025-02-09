/// An algebraic data type for shapes.
enum Shape {
    case Circle(Int32),          // circle radius
    case Square(Int32),          // side length
    case Rectangle(Int32, Int32) // height and width
}

/// Computes the area of the given shape using
/// pattern matching and basic arithmetic.
def area(s: Shape): Int32 = match s {
    case Shape.Circle(r)       => 3 * (r * r)
    case Shape.Square(w)       => w * w
    case Shape.Rectangle(h, w) => h * w
}


enum Send[_a]

enum Receive[_a]

enum ChoiceOffer[_a]

enum ChoiceSelection[_a]

enum Recursion[_a]

enum Var[_a]

enum Empty

trait HasDual[t] {
    type Dual
}


instance HasDual[Empty] {
    type Dual = Empty
}

instance HasDual[Send[a]] {
    type Dual = Receive[a]
}

instance HasDual[Receive[a]] {
    type Dual = Send[a]
}

instance HasDual[ChoiceOffer[a]] {
    type Dual = ChoiceSelection[a]
}

instance HasDual[ChoiceSelection[a]] {
    type Dual = ChoiceOffer[a]
}

instance HasDual[Recursion[a]] {
    type Dual = ChoiceOffer[a]
}

enum Channel[_a]

enum Cap[_e, _r]

enum Session[_s, _ss, _a]


def send(elem: elem ) : Unit = () 


trait IxMonad[m: Type -> Type -> Type -> Type ] {
    pub def >>>=(e: m[i, j, a], f: (a -> m[j, k, b])) : m[i, k, b]
    pub def >>>-(e1: m[i, j, a], e2: m[j, k, b]) : m[i, k, b]
}

instance IxMonad[Session] {

    pub def >>>=(e: Session[i, j, a], f: a -> Session[j, k, b]): Session[i, k, b] = ???

    pub def >>>-(e1: Session[i, j, a], e2: Session[j, k, b]): Session[i, k, b] = e1 (IxMonad.>>>=) (_ -> e2)

}


// Computes the area of a 2 by 4.
def main(): Unit \ IO =
    area(Shape.Rectangle(2, 4)) |> println
