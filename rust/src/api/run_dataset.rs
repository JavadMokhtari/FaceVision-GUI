use facevision_parallel::{
    detect_face_from_dataset, extract_feature_from_dataset, match_features_cross_datasets,
};

pub fn detect_face(
    src_dir: String,
    dst_dir: String,
    img_size: u32,
    confidence: f32,
    iou: f32,
    recursive: bool,
    shard: Option<(usize, usize)>,
    save_faces: bool,
    verbose: bool,
) -> Result<(), String> {
    match detect_face_from_dataset(
        &src_dir, &dst_dir, img_size, confidence, iou, recursive, shard, save_faces, verbose,
    ) {
        Ok(_) => Ok(()),
        Err(e) => Err(e.to_string()),
    }
}

pub fn extract_feature(
    src_dir: String,
    dst_dir: String,
    model_name: String,
    recursive: bool,
    quantized: bool,
    shard: Option<(usize, usize)>,
    verbose: bool,
) -> Result<(), String> {
    match extract_feature_from_dataset(
        &src_dir,
        &dst_dir,
        &model_name,
        recursive,
        quantized,
        shard,
        verbose,
    ) {
        Ok(_) => Ok(()),
        Err(e) => Err(e.to_string()),
    }
}

pub fn match_feature(
    ref_dir: String,
    probe_dir: String,
    output_dir: String,
    recursive: bool,
    is_quantized: bool,
    feature_exts: Vec<String>,
    verbose: bool,
) -> Result<(), String> {
    let feature_exts_slice: Vec<&str> = feature_exts.iter().map(|s| s.as_str()).collect();
    match match_features_cross_datasets(
        &ref_dir,
        &probe_dir,
        &output_dir,
        recursive,
        is_quantized,
        &feature_exts_slice,
        verbose,
    ) {
        Ok(_) => Ok(()),
        Err(e) => Err(e.to_string()),
    }
}
