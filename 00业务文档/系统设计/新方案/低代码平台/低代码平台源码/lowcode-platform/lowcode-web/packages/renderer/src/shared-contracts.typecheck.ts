import type {
  FieldPermissionMap,
  PageSchema as SharedPageSchema,
  RuntimePageSchema as SharedRuntimePageSchema
} from "@lowcode/shared";
import type { PageSchema, RuntimeMeta, RuntimePageSchema } from "./index";

type Assert<T extends true> = T;

type IsSameType<Left, Right> = [Left] extends [Right]
  ? ([Right] extends [Left] ? true : false)
  : false;

export type PageSchemaReusesSharedContract = Assert<IsSameType<PageSchema, SharedPageSchema>>;
export type RuntimePageSchemaReusesSharedContract = Assert<IsSameType<RuntimePageSchema, SharedRuntimePageSchema>>;
export type RuntimeMetaPermissionsReuseSharedContract = Assert<
  IsSameType<RuntimeMeta["permissions"], FieldPermissionMap>
>;
