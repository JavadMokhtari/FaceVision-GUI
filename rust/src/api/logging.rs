//! This is the entire frb surface needed for plain-text log capture —
//! one function, one built-in return type, nothing to fight with codegen over.

use flutter_rust_bridge::frb;

#[frb]
pub fn drain_log_lines() -> Vec<String> {
    facevision_parallel::logging::drain_log_lines()
}
