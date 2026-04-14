export const createText = (
    text: { content: string; link: string | null },
    annotations?: object,
    href: string | null = null,
) => {
    return {
        type: 'text',
        text: {
            ...text,
            link: null,
        },
        annotations,
        plain_text: text.content,
        href,
    };
};

export const createRichText = (text: ReturnType<typeof createText>, color: 'default' | 'gray' | 'blue' = 'default') => {
    return {
        rich_text: [text],
        color,
    };
};

export const createDivider = () => ({
    type: 'divider',
    divider: {},
});

export const createParagraph = (text: string, href: string | null = null, children: Array<object> | null = null) => ({
    object: 'block',
    has_children: false,
    archived: false,
    in_trash: false,
    type: 'paragraph',
    paragraph: {
        rich_text: [
            {
                type: 'text',
                text: {
                    content: text,
                    link: href ? { url: href } : null,
                },
                annotations: {
                    bold: true,
                    italic: false,
                    strikethrough: false,
                    underline: false,
                    code: false,
                    color: 'gray',
                },
                plain_text: text,
                href,
            },
        ],
        color: 'default',
        ...(children && { children }),
    },
});
