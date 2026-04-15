type Callout = {
    icon: {
        type: 'emoji';
        emoji: string;
    };
    rich_text: Array<object>;
    children: Array<object>;
};

export const createCallout = (icon: string, richText: object, children: Array<object>): Callout => {
    return {
        icon: {
            type: 'emoji',
            emoji: icon,
        },
        rich_text: [richText],
        children,
    };
};
