#[test]
fn cargo_build_script_compiled_resource_dir_probe() {
    assert_eq!(env!("RESOURCE_DIR_PROBE_COMPILED"), "1");
}
