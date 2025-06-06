def ordinal(n: int):
    if 11 <= (n % 100) <= 13:
        suffix = 'th'
    else:
        suffix = ['th', 'st', 'nd', 'rd', 'th'][min(n % 10, 4)]
    return str(n) + suffix

num_branches = 6

# Create the enum definitions 
offers = []
selections = []
aliases = []
for i in range(2, num_branches+1):
    comma_separated_branches = ", ".join([f"_branch{j + 1}" for j in range(i)])
    
    offers.append(f"// Represents offering between {i} different branch protocols")
    offers.append(f"enum ChoiceOffer{i}[{comma_separated_branches}]\n")
    selections.append(f"// Represents selecting between {i} different branch protocols")
    selections.append(f"enum ChoiceSelection{i}[{comma_separated_branches}]\n") 

# Create the type aliases
for i in range(2, num_branches+1):
    comma_separated_protocols = ", ".join([f"protocol{k + 1}" for k in range(i)])
    aliases.append(f"type alias Sel{i}[{comma_separated_protocols}] = ChoiceSelection{i}[{comma_separated_protocols}]")
for i in range(2, num_branches+1):
    comma_separated_protocols = ", ".join([f"protocol{k + 1}" for k in range(i)])
    aliases.append(f"type alias Off{i}[{comma_separated_protocols}] = ChoiceOffer{i}[{comma_separated_protocols}]")

# Create the dual declarations
duals = []
for i in range(2, num_branches+1):
    comma_separated_protocols = ", ".join([f"protocol{k + 1}" for k in range(i)])
    comma_separated_has_duals = ", ".join([f"HasDual[protocol{k+1}]" for k in range(i)])
    comma_separated_has_duals_duals = ", ".join([f"HasDual.Dual[protocol{k+1}]" for k in range(i)])
    duals.append(f"""
// ChoiceOffer{i}'s dual is ChoiceSelection{i} with dual branches
instance HasDual[ChoiceOffer{i}[{comma_separated_protocols}]] 
    with {comma_separated_has_duals} 
    {{
        type Dual = ChoiceSelection{i}[{comma_separated_has_duals_duals}]
    }}

""")

for i in range(2, num_branches+1):
    comma_separated_protocols = ", ".join([f"protocol{k + 1}" for k in range(i)])
    comma_separated_has_duals = ", ".join([f"HasDual[protocol{k+1}]" for k in range(i)])
    comma_separated_has_duals_duals = ", ".join([f"HasDual.Dual[protocol{k+1}]" for k in range(i)])
    duals.append(f"""
// ChoiceSelection{i}'s dual is ChoiceOffer{i} with dual branches
instance HasDual[ChoiceSelection{i}[{comma_separated_protocols}]] 
    with {comma_separated_has_duals} 
    {{
        type Dual = ChoiceOffer{i}[{comma_separated_has_duals_duals}]
    }}

""")



# Create the selection methods
selection_methods = []
for i in range(2, num_branches+1):
    comma_separated_protocols = ", ".join([f"protocol{k + 1}" for k in range(i)])
    for j in range(1, i+1):
        selection_methods.append(
f"""
/**
 * Select the {ordinal(j)} branch in a choice out of {i} elements
 */
pub def sel_{j}_from_{i}(): 
    Session[Cap[_env, ChoiceSelection{i}[{comma_separated_protocols}]], Cap[_env, protocol{j}], Unit, Chan] = 
    Session.Session(match (sender, _receiver) -> 
        Channel.send({j}i8 |> toObject, sender)
    )
""")

# Create the offer methods
offer_methods = []
for i in range(2, num_branches+1):
    comma_separated_protocols = ", ".join([f"protocol{k + 1}" for k in range(i)])
    option_args = ",\n".join([f"   option{j}: {{option{j} = Session[Cap[_env, protocol{j}], endState, resultType, effects{j}]}}" for j in range(1, i+1)])
    effects_result = " + ".join([f"effects{j}" for j in range(1, i+1)])
    cases = "\n".join([f"""
            case {j}i8 =>
                let Session.Session(handlr{j}) = option{j}#option{j};
                handlr{j}(channel) 
""" for j in range(1, i +1)])
    offer_methods.append(
f"""
/**
 * Handle an offered choice by providing handlers for all {i} possible branches
 */
pub def session_offer_{i} (
{option_args}  
) : Session[Cap[_env, ChoiceOffer{i}[{comma_separated_protocols}]], endState, resultType, {effects_result} + Chan + NonDet] = 
    Session.Session(channel ->
        let (_sender, receiver) = channel; 
        let choice = Channel.recv(receiver) |> fromObject;
        match choice {{
            {cases}
            case _ => unreachable!()
        }}
    )
""")



 


for offer in offers:
    print(offer)
for selection in selections:
    print(selection)
for alias in aliases:
    print(alias)
for dual in duals:
    print(dual)
for method in selection_methods:
    print(method)
for method in offer_methods:
    print(method)