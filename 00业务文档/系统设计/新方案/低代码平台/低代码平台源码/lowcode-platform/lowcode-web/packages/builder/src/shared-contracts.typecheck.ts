import type {
  PageSchema as SharedPageSchema,
  PageType as SharedPageType
} from "@lowcode/shared";
import type { SessionPageSchema, SessionPageType } from "./index";

type Assert<T extends true> = T;

type IsSameType<Left, Right> = [Left] extends [Right]
  ? ([Right] extends [Left] ? true : false)
  : false;

type BuilderPageShape = Omit<SessionPageSchema, "objectCode">;

export type SessionPageTypeReusesSharedContract = Assert<IsSameType<SessionPageType, SharedPageType>>;
export type SessionPageSchemaExtendsSharedContract = Assert<BuilderPageShape extends SharedPageSchema ? true : false>;
