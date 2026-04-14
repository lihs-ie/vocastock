export const createBlock = (callout: object | null = null, paragraph: object | null = null) => ({
    object: 'block',
    archived: false,
    ...callout,
    ...paragraph,
});
