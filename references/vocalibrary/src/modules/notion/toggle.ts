export const createToggle = (parentRichText: Array<object>, children: Array<object>) => {
    return {
        object: 'block',
        has_children: true,
        archived: false,
        in_trash: false,
        type: 'toggle',
        toggle: {
            rich_text: parentRichText,
            color: 'default',
            children,
        },
    };
};
