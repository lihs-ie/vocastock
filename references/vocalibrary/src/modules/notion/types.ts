type User = {
    object: string;
    id: string;
};

type Status = {
    id: string;
    name: string;
    color: string;
};

type Select = {
    id: string;
    name: string;
    color: string;
};

type Text = {
    type: string;
    text: {
        content: string;
        link: null;
    };
    annotations: {
        bold: boolean;
        italic: boolean;
        strikethrough: boolean;
        underline: boolean;
        code: boolean;
        color: string;
    };
    plain_text: string;
    href: null;
};

type Properties = {
    習得度: {
        id: string;
        type: string;
        status: Status;
    };
    頻出度: {
        id: string;
        type: string;
        select: Select;
    };
    知的度: {
        id: string;
        type: string;
        select: Select;
    };
    Vocabulary: {
        id: string;
        type: string;
        title: Text[];
    };
};

export type Page = {
    object: string;
    id: string;
    created_time: string;
    last_edited_time: string;
    created_by: User;
    last_edited_by: User;
    cover: null;
    icon: null;
    parent: {
        type: string;
        database_id: string;
    };
    archived: boolean;
    in_trash: boolean;
    properties: Properties;
    url: string;
    public_url: null;
};
