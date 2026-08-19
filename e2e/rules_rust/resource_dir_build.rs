use std::env;
use std::process::Command;

fn main() {
    let manifest_dir = env::var("CARGO_MANIFEST_DIR").expect("CARGO_MANIFEST_DIR is set");
    let current_dir = env::current_dir().expect("current directory is available");
    let manifest_dir =
        std::fs::canonicalize(manifest_dir).expect("manifest directory is available");
    assert_eq!(current_dir, manifest_dir);

    let status = Command::new("/bin/sh")
        .args([
            "-c",
            r#"CFLAGS="-nobuiltininc $CFLAGS"; "$CC" $CFLAGS -c resource_dir_probe.c -o "$OUT_DIR/resource_dir_probe.o""#,
        ])
        .status()
        .expect("run C compiler through /bin/sh");
    assert!(status.success(), "C probe compilation failed");

    println!("cargo:rustc-env=RESOURCE_DIR_PROBE_COMPILED=1");
}
