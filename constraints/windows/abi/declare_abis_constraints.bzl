load(":abis.bzl", "ABIS")

def declare_abis_constraints():
    native.constraint_setting(
        name = "abi",
        default_constraint_value = "unconstrained",  # For windows, this maps to a default gnu
    )
    native.constraint_value(
        name = "unconstrained",
        constraint_setting = ":abi",
    )

    for abi in ABIS:
        native.constraint_value(
            name = abi,
            constraint_setting = ":abi",
        )
