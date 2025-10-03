import Foundation

public enum ProjectPathSegmentType: String, RawRepresentable, Sendable {
    case directory
    case file

    public static func from(_ is_dir_obj_c: ObjCBool) -> ProjectPathSegmentType {
        return  is_dir_obj_c.boolValue ? .directory : .file
    }
}
