//! Exposes the Hayagriva version pinned in `Cargo.lock` as the
//! `TYPST_HAYAGRIVA_VERSION` environment variable, so that the docs can link
//! to the documentation matching the version Typst actually ships.

use std::fs;
use std::path::Path;

fn main() {
    let lock = Path::new(env!("CARGO_MANIFEST_DIR")).join("../Cargo.lock");
    println!("cargo:rerun-if-changed={}", lock.display());

    let text = fs::read_to_string(&lock).expect("failed to read Cargo.lock");
    let version = text
        .split("[[package]]")
        .filter(|block| block.lines().any(|l| l.trim() == "name = \"hayagriva\""))
        .find_map(|block| {
            block.lines().find_map(|l| {
                l.strip_prefix("version = \"")?.strip_suffix('"').map(str::to_owned)
            })
        })
        .expect("hayagriva not found in Cargo.lock");

    println!("cargo:rustc-env=TYPST_HAYAGRIVA_VERSION={version}");
}
