const annotations = {
    bold: false,
    italic: false,
    strikethrough: false,
    underline: false,
    code: false,
    color: 'gray',
};

export const createAnnotation = (overrides?: {
    [key in keyof typeof annotations]?: unknown;
}) => {
    return {
        ...annotations,
        ...overrides,
    };
};

export const createParagraph = (content: string, annotations?: object) => {
    return {
        type: 'paragraph',
        paragraph: {
            rich_text: [
                {
                    type: 'text',
                    text: {
                        content,
                        link: null,
                    },
                    annotations,
                    plain_text: content,
                    href: null,
                },
            ],
            color: 'default',
        },
    };
};
